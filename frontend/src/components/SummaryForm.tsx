"use client"

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Loader2 } from 'lucide-react'

interface SummaryFormProps {
  onSubmit: (data: {
    source: string
    media_id: string
    target_name?: string
  }) => void
  loading: boolean
  isDark: boolean
}

const sourceOptions = [
  { value: 'myanimelistmanga', label: 'MyAnimeList Manga' },
  { value: 'myanimelistanime', label: 'MyAnimeList Anime' },
  { value: 'openlibrary', label: 'Open Library' },
  { value: 'themoviedb', label: 'TMDB (Movies/TV)' },
]

export default function SummaryForm({ onSubmit, loading, isDark }: SummaryFormProps) {
  const [source, setSource] = useState('')
  const [mediaId, setMediaId] = useState('')
  const [targetName, setTargetName] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!source || !mediaId) {
      return
    }

    const formData: any = {
      source,
      media_id: mediaId,
    }

    if (source === 'myanimelistanime' && targetName) {
      formData.target_name = targetName
    }

    onSubmit(formData)
  }

  const isAnimeSource = source === 'myanimelistanime'

  return (
    <Card className={`transition-colors duration-300 ${
      isDark 
        ? 'bg-gray-800 border-gray-700' 
        : 'bg-white border-gray-200 shadow-lg'
    }`}>
      <CardHeader>
        <CardTitle className={isDark ? 'text-white' : 'text-gray-900'}>
          Media Information
        </CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="source" className={isDark ? 'text-gray-200' : 'text-gray-700'}>
              Source
            </Label>
            <Select value={source} onValueChange={setSource}>
              <SelectTrigger className={`transition-colors duration-300 ${
                isDark 
                  ? 'bg-gray-700 border-gray-600 text-white' 
                  : 'bg-white border-gray-300 text-gray-900'
              }`}>
                <SelectValue placeholder="Select a media source" />
              </SelectTrigger>
              <SelectContent className={isDark ? 'bg-gray-700 border-gray-600' : 'bg-white border-gray-200'}>
                {sourceOptions.map((option) => (
                  <SelectItem 
                    key={option.value} 
                    value={option.value}
                    className={`transition-colors ${
                      isDark 
                        ? 'text-white hover:bg-gray-600' 
                        : 'text-gray-900 hover:bg-gray-100'
                    }`}
                  >
                    {option.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-2">
            <Label htmlFor="media_id" className={isDark ? 'text-gray-200' : 'text-gray-700'}>
              Media ID
            </Label>
            <Input
              id="media_id"
              type="text"
              value={mediaId}
              onChange={(e) => setMediaId(e.target.value)}
              placeholder="Enter the media ID (e.g., 550, OL45804W)"
              className={`transition-colors duration-300 ${
                isDark 
                  ? 'bg-gray-700 border-gray-600 text-white placeholder-gray-400' 
                  : 'bg-white border-gray-300 text-gray-900 placeholder-gray-500'
              }`}
              required
            />
          </div>

          {isAnimeSource && (
            <div className="space-y-2">
              <Label htmlFor="target_name" className={isDark ? 'text-gray-200' : 'text-gray-700'}>
                Episode/Target
              </Label>
              <Input
                id="target_name"
                type="text"
                value={targetName}
                onChange={(e) => setTargetName(e.target.value)}
                placeholder="Enter episode (e.g., Episode 1)"
                className={`transition-colors duration-300 ${
                  isDark 
                    ? 'bg-gray-700 border-gray-600 text-white placeholder-gray-400' 
                    : 'bg-white border-gray-300 text-gray-900 placeholder-gray-500'
                }`}
              />
            </div>
          )}

          <Button
            type="submit"
            disabled={loading || !source || !mediaId}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-50 transition-colors duration-300"
          >
            {loading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Summarizing...
              </>
            ) : (
              'Summarize'
            )}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}
