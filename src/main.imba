import honk from '/assets/honk.mp3'

class AudioProvider
	prop analyser
	prop dataArray
	prop rawData
	prop source

	def init
		const res = await global.fetch('/assets/honk.mp3')
		const byteArray = await res.arrayBuffer()
		const context = new global.AudioContext()
		const audioBuffer = await context.decodeAudioData(byteArray)
		source = context.createBufferSource()
		source.buffer = audioBuffer
		analyser = context.createAnalyser()
		analyser.fftSize = 512
		source.connect(analyser)
		source.start()
		const bufferLength = analyser.frequencyBinCount
		dataArray = new Uint8Array(bufferLength)

	def update
		analyser.getByteFrequencyData(dataArray)
		const orig = Array.from(dataArray)
		rawData = [[...orig].reverse(), orig].flat()
		# imba.commit()

let ap = new AudioProvider

tag App
	def mount
		await ap.init()

	<self>
		<audio controls src=honk>
		# console.log(ap.rawData)
		<pre> "{JSON.stringify(ap.dataArray)}"
		await ap.update()

imba.mount <App>
