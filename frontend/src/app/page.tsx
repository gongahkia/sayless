"use client"

import { useState, useEffect } from 'react'
import SummaryForm from '@/components/SummaryForm'
import SummaryDisplay from '@/components/SummaryDisplay'
import { Heart, Sun, Moon } from 'lucide-react'

interface SummaryData {
  characters: string[]
  key_events: string
  plot_points: string[]
}

interface ApiResponse {
  data: {
    summary: SummaryData
  }
}

interface ApiError {
  errors: {
    detail: string
  }
}

export default function App() {
  const [summaryData, setSummaryData] = useState<SummaryData | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const [isDark, setIsDark] = useState(true)

  const handleSummarize = async (formData: {
    source: string
    media_id: string
    target_name?: string
  }) => {
    setLoading(true)
    setError(null)
    setSummaryData(null)

    try {
      const requestBody: any = {
        source: formData.source,
        media_id: formData.media_id
      }

      if (formData.source === 'myanimelistanime' && formData.target_name) {
        requestBody.target_name = formData.target_name
      }

      const response = await fetch('http://localhost:4000/api/v1/summarize', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      })

      if (response.ok) {
        const data: ApiResponse = await response.json()
        setSummaryData(data.data.summary)
      } else {
        const errorData: ApiError = await response.json()
        setError(errorData.errors.detail)
      }
    } catch (err) {
      setError('Failed to connect to the server. Please make sure the backend is running.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className={`min-h-screen transition-colors duration-300 ${
      isDark ? 'bg-gray-900 text-white' : 'bg-gray-50 text-gray-900'
    }`}>
      {/* Theme Toggle - Top Right */}
      <div className="absolute top-4 right-4 z-10">
        <button
          onClick={() => setIsDark(!isDark)}
          className={`p-3 rounded-lg border transition-all duration-300 hover:scale-110 ${
            isDark 
              ? 'bg-gray-800 border-gray-700 text-yellow-400 hover:bg-gray-700' 
              : 'bg-white border-gray-300 text-gray-600 hover:bg-gray-100'
          }`}
          title={`Switch to ${isDark ? 'light' : 'dark'} mode`}
        >
          {isDark ? <Sun className="w-5 h-5" /> : <Moon className="w-5 h-5" />}
        </button>
      </div>

      <div className="container mx-auto px-4 py-8">
        <div className="max-w-2xl mx-auto">
          <div className="text-center mb-8">
            <h1 className="text-4xl font-bold mb-2">SayLess</h1>
            <p className={isDark ? 'text-gray-400' : 'text-gray-600'}>
              Get AI-powered summaries of your favorite media
            </p>
          </div>

          <div>
            <SummaryForm onSubmit={handleSummarize} loading={loading} isDark={isDark} />
          </div>

          {error && (
            <div className={`mt-6 p-4 border rounded-lg ${
              isDark 
                ? 'border-red-500 bg-red-500/10 text-red-400' 
                : 'border-red-400 bg-red-50 text-red-600'
            }`}>
              <p>{error}</p>
            </div>
          )}

          {summaryData && (
            <div>
              <SummaryDisplay summary={summaryData} isDark={isDark} />
            </div>
          )}
        </div>
      </div>
      
      <footer className="mt-12 text-center">
        <p className={`text-sm flex items-center justify-center gap-1 flex-wrap ${
          isDark ? 'text-gray-400' : 'text-gray-600'
        }`}>
          Made with <Heart className="w-4 h-4 text-red-500 fill-current" /> by{' '}
          <a 
            href="https://gabrielongzm.com" 
            target="_blank" 
            rel="noopener noreferrer"
            className="text-blue-500 hover:text-blue-400 transition-colors underline"
          >
            Gabriel Ong
          </a>
          <span className="mx-2">•</span>
          Source code{' '}
          <a 
            href="https://github.com/gongahkia/sayless" 
            target="_blank" 
            rel="noopener noreferrer"
            className="text-blue-500 hover:text-blue-400 transition-colors underline"
          >
            here
          </a>
        </p>
      </footer>
    </div>
  )
}