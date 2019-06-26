// Configure path to bitcoin-spv merkle proof script.
const merkleScript = "/Users/jakub/workspace/bitcoin-spv/scripts/merkle.py"

let fundingProof = {}

function initialize() {
    console.log("Install python environment...")

    const { spawn } = require('child_process');

    const spawnProcess = spawn('pipenv', ['install'])

    spawnProcess.stdout.on('data', (data) => {
        console.log(`${data}`);
    });

    spawnProcess.stderr.on('data', (data) => {
        console.error(`Failure:\n${data}`)
        process.exit(1)
    });

    spawnProcess.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
    });
}

export async function getTransactionProof(txID, headerLen, callback) {
    console.log("Get transaction proof...")

    if (txID == undefined || txID.length < 64) {
        console.error('missing txID argument');
        process.exit(1)
    }

    console.log(`Transaction ID: ${txID}`)

    await getBitcoinSPVproof(txID, headerLen, callback)
}

async function getBitcoinSPVproof(txID, headerLen, callback) {
    console.log("Get bitcoin-spv proof...")

    const { spawn } = require('child_process')

    let spawnProcess = spawn('pipenv', ['run', 'python', merkleScript, txID, headerLen])

    spawnProcess.stdout.on('data', data => {
        console.log(`Received data from bitcoin-spv`);
        let spvProof = parseBitcoinSPVOutput(data.toString())

        fundingProof.merkleProof = spvProof.merkleProof
        fundingProof.txInBlockIndex = spvProof.txInBlockIndex
        fundingProof.chainHeaders = spvProof.chainHeaders

        parseTransaction(spvProof.tx, callback)
    });

    spawnProcess.stderr.on('data', (data) => {
        console.error(`Failure:\n${data}`)
        process.exit(1)
    });

    spawnProcess.on('close', (code) => {
        console.log(`child process exited with code ${code}`);
        return
    });
}

function parseBitcoinSPVOutput(output) {
    console.log("Parse bitcoin-spv output...\n")

    let tx = hexToBytes(output.match(/(^-* TX -*$\n)^(.*)$/m)[2])
    let merkleProof = hexToBytes(output.match(/(^-* PROOF -*$\n)^(.*)$/m)[2])
    let txInBlockIndex = output.match(/(^-* INDEX -*$\n)^(.*)$/m)[2]
    let chainHeaders = hexToBytes(output.match(/(^-* CHAIN -*$\n)^(.*)$/m)[2])

    return {
        tx: tx,
        merkleProof: merkleProof,
        txInBlockIndex: txInBlockIndex,
        chainHeaders: chainHeaders
    };
}

async function parseTransaction(tx, callback) {
    console.log("Parse transaction...\nTX:", bytesToHex(tx))

    if (tx.length == 0) {
        console.error("cannot decode the transaction", bytesToHex(tx))
        process.exit(1)
    }

    fundingProof.version = getVersion(tx)
    fundingProof.txInVector = getTxInputVector(tx)
    fundingProof.txOutVector = getTxOutputVector(tx)
    fundingProof.locktime = getLocktime(tx)
    // TODO: Find index in transaction based on deposit's public key
    // fundingProof.fundingOutputIndex 
    let serializedProof = serializeProof(fundingProof)

    console.log("Funding Proof:", serializedProof)

    callback(fundingProof)
}

function serializeProof(fundingProof) {
    return {
        merkleProof: bytesToHex(fundingProof.merkleProof),
        txInBlockIndex: fundingProof.txInBlockIndex,
        chainHeaders: bytesToHex(fundingProof.chainHeaders),
        version: bytesToHex(fundingProof.version),
        txInVector: bytesToHex(fundingProof.txInVector),
        txOutVector: bytesToHex(fundingProof.txOutVector),
        locktime: bytesToHex(fundingProof.locktime),
    }
}

function getPrefix(tx) {
    if (isFlagPresent(tx)) {
        return tx.slice(0, 6)
    }
    return tx.slice(0, 4)
}

function getVersion(tx) {
    return tx.slice(0, 4)
}

function isFlagPresent(tx) {
    if (tx.slice(4, 6).equals(Buffer.from('0001', 'hex'))) {
        return true
    }

    return false
}

function getTxInputVector(tx) {
    let txInVectorStartPosition = getPrefix(tx).length
    let txInVectorEndPosition

    if (isFlagPresent(tx)) {
        // TODO: Implement for witness transaction
        console.log("witness is not fully supported")
        txInVectorEndPosition = txInVectorStartPosition + 42
    } else {
        let inputCount = tx.slice(txInVectorStartPosition, txInVectorStartPosition + 1).readIntBE(0, 1)

        if (inputCount != 1) {
            // TODO: Support multiple inputs
            console.error(`exactly one input is required, got [${inputCount}]`);
            process.exit(1)
        } else {
            let startPos = txInVectorStartPosition + 1

            let previousHash = tx.slice(startPos, startPos + 32).reverse()

            let previousOutIndex = tx.slice(startPos + 32, startPos + 36).readIntBE(0, 4)

            let scriptLength = tx.slice(startPos + 36, startPos + 37).readIntBE(0, 1)
            if (scriptLength >= 253) {
                console.error(`VarInts not supported`);
                process.exit(1)
            }

            let script = tx.slice(startPos + 37, startPos + 37 + scriptLength)

            let sequenceNumber = tx.slice(startPos + 37 + scriptLength, startPos + 37 + scriptLength + 4)

            txInVectorEndPosition = startPos + 37 + scriptLength + 4
        }
    }

    return tx.slice(txInVectorStartPosition, txInVectorEndPosition)
}

function getTxOutputVector(tx) {
    let outStartPosition = getTxOutputVectorPosition(tx)
    let outputsCount = getNumberOfOutputs(tx)

    let startPosition = outStartPosition + 1
    let outEndPosition

    for (let i = 0; i < outputsCount; i++) {
        let value = tx.slice(startPosition, startPosition + 8)
        let scriptLength = tx.slice(startPosition + 8, startPosition + 8 + 1).readIntBE(0, 1)

        if (scriptLength >= 253) {
            console.error(`VarInts not supported`);
            process.exit(1)
        }

        let script = tx.slice(startPosition + 8 + 1, startPosition + 8 + 1 + scriptLength)

        outEndPosition = startPosition + 8 + 1 + scriptLength
        startPosition = outEndPosition
    }

    return tx.slice(outStartPosition, outEndPosition)
}

function getTxOutputVectorPosition(tx) {
    let txPrefix = getPrefix(tx)
    let txInput = getTxInputVector(tx)

    return txPrefix.length + txInput.length
}

function getNumberOfOutputs(tx) {
    let outStartPosition = getTxOutputVectorPosition(tx)

    return tx.slice(outStartPosition, outStartPosition + 1).readIntBE(0, 1)
}

function getTxOutputAtIndex(tx, index) {
    outputsCount = getNumberOfOutputs(tx)
    if (index > getNumberOfOutputs(tx)) {
        console.error(`index [${index}] greater than number of outputs [${outputsCount}]`)
        process.exit(1)
    }

    let outStartPosition = getTxOutputVectorPosition(tx) + 1
    let outEndPosition = outStartPosition
    let scriptLength

    for (let i = 0; i <= index; i++) {
        outStartPosition = outEndPosition

        scriptLength = tx.slice(outStartPosition + 8, outStartPosition + 8 + 1).readIntBE(0, 1)

        outEndPosition = outStartPosition + 8 + 1 + scriptLength
    }

    return tx.slice(outStartPosition, outEndPosition);
}

function getLocktime(tx) {
    return tx.slice(tx.length - 4)
}

export function hexToBytes(hex) {
    return Buffer.from(hex, 'hex');
}

export function bytesToHex(bytes) {
    let buffer = Buffer.from(bytes);
    return buffer.toString('hex')
}

// await initialize();
// await getTransactionProof(txID, headerLen, parseTransaction(spvProof.tx, callback));
    // txStr = "01000000017b2ebd539bb3eea541dd17f37db6db5f455f5543461756648d7203c58ac5a320010000006b483045022100d58e3be72e79b2e3872ebf5a73c9da999de05918f5aa7fb60e56793613decc4d022022aa77511f3b156b1ce42f97343ac43b0a23fd12f8dad6269fdd96acd893256c0121028896955d043b5a43957b21901f2cce9f0bfb484531b03ad6cd3153e45e73ee2effffffff022823000000000000160014d849b1e1cede2ac7d7188cf8700e97d6975c91c400ac0d00000000001976a914d849b1e1cede2ac7d7188cf8700e97d6975c91c488ac00000000"

    // tx = web3.utils.hexToBytes('0x' + txStr)
    // await parseTransaction(txStr);
// }
