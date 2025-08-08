import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

interface SummaryData {
  characters: string[]
  key_events: string
  plot_points: string[]
}

interface SummaryDisplayProps {
  summary: SummaryData
  isDark: boolean
}

export default function SummaryDisplay({ summary, isDark }: SummaryDisplayProps) {
  return (
    <div className="mt-6 space-y-4">
      <Card className={`transition-colors duration-300 ${
        isDark 
          ? 'bg-gray-800 border-gray-700' 
          : 'bg-white border-gray-200 shadow-lg'
      }`}>
        <CardHeader>
          <CardTitle className={`flex items-center gap-2 ${
            isDark ? 'text-white' : 'text-gray-900'
          }`}>
            <span className="text-green-500">✓</span>
            Summary Generated
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Characters Section */}
          <div>
            <h3 className={`text-lg font-semibold mb-3 ${
              isDark ? 'text-white' : 'text-gray-900'
            }`}>
              Characters
            </h3>
            <ul className="space-y-1">
              {summary.characters.map((character, index) => (
                <li key={index} className={`flex items-start ${
                  isDark ? 'text-gray-300' : 'text-gray-700'
                }`}>
                  <span className="text-blue-500 mr-2">•</span>
                  {character}
                </li>
              ))}
            </ul>
          </div>

          {/* Key Events Section */}
          <div>
            <h3 className={`text-lg font-semibold mb-3 ${
              isDark ? 'text-white' : 'text-gray-900'
            }`}>
              Key Events
            </h3>
            <p className={`leading-relaxed ${
              isDark ? 'text-gray-300' : 'text-gray-700'
            }`}>
              {summary.key_events}
            </p>
          </div>

          {/* Plot Points Section */}
          <div>
            <h3 className={`text-lg font-semibold mb-3 ${
              isDark ? 'text-white' : 'text-gray-900'
            }`}>
              Plot Points
            </h3>
            <ul className="space-y-2">
              {summary.plot_points.map((point, index) => (
                <li key={index} className={`flex items-start ${
                  isDark ? 'text-gray-300' : 'text-gray-700'
                }`}>
                  <span className="text-blue-500 mr-2">•</span>
                  {point}
                </li>
              ))}
            </ul>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
