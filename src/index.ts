import 'dotenv/config'
import express from 'express'
import cors from 'cors'
import multer from 'multer'
import { BlobServiceClient } from '@azure/storage-blob'
import { PrismaClient } from '@prisma/client'

const app = express()
const prisma = new PrismaClient()
const upload = multer({ storage: multer.memoryStorage() });

app.use(cors())
app.use(express.json())

app.get('/health', (_, res) => res.json({ ok: true}))

app.get('/books', async (_, res) => {
  const books = await prisma.book.findMany({ orderBy: { id: 'desc' }})
  res.json(books)
})

app.post('/books', async (req, res) => {
    const { title, author, priceCents, imageUrl } = req.body
    if (!title || !author || typeof priceCents !== 'number') {
        return res.status(400).json({ error: 'Invalid Payload' })
    }

    const book = await prisma.book.create({ data: { title, author, priceCents, imageUrl }})
    res.status(201).json(book)
})

app.post('/upload', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' })
    }

    const connectionString = process.env.AZURE_STORAGE_CONNECTION_STRING
    const containerName = process.env.AZURE_STORAGE_CONTAINER || 'book-images'

    if (!connectionString) {
      return res.status(500).json({ error: 'Missing Azure connection string' })
    }

    const blobServiceClient = BlobServiceClient.fromConnectionString(connectionString)
    const containerClient = blobServiceClient.getContainerClient(containerName)

    // Unique blob name (timestamp + original name)
    const blobName = `${Date.now()}-${req.file.originalname}`
    const blockBlobClient = containerClient.getBlockBlobClient(blobName)

    // Upload the file
    await blockBlobClient.uploadData(req.file.buffer, {
      blobHTTPHeaders: { blobContentType: req.file.mimetype },
    })

    const imageUrl = blockBlobClient.url
    console.log('Uploaded:', imageUrl)

    res.json({ imageUrl })
  } catch (err) {
    console.error('Upload failed:', err)
    res.status(500).json({ error: 'Failed to upload image' })
  }
})

const port = Number(process.env.PORT) || 4000
app.listen(port, () => console.log(`Àpi listening on :${port}`))