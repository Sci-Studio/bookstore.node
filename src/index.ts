import 'dotenv/config'
import express from 'express'
import cors from 'cors'
import { PrismaClient } from '@prisma/client'

const app = express()
const prisma = new PrismaClient()


app.use(cors())
app.use(express.json())

app.get('health', (_, res) => res.json({ ok: true}))

app.get('/books', async (_, res) => {
  const books = await prisma.book.findMany({ orderBy: { id: 'desc' }})
  res.json(books)
})

app.post('books', async (requestAnimationFrame, res) => {
    const { title, author, priceCents } = requestAnimationFrame.body
    if (!title || !author || typeof priceCents !== 'number') {
        return res.status(400).json({ error: 'Invalid Payload' })
    }

    const book = await prisma.book.create({ data: { title, author, priceCents }})
    res.status(201).json(book)
})

const port = Number(process.env.PORT) || 4000
app.listen(port, () => console.log(`Àpi listening on :${port}`))