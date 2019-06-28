#!/bin/bash
# Based on a post in 
# https://stackoverflow.com/questions/33466130/linux-create-animated-gif-with-pan-and-zoom

#TODO get those from arguments
let zoom_factor=2
x=75
y=50
filename=test.gif
time=2
#END TODO

delay=$(identify -verbose -format "Frame %s: %Tcs | Duration: %[Iterations]\n" $filename | grep -P -o "(?<=Frame 0: )\d+")
steps=$(( time * 100 / delay))

echo $steps
frames=$(identify $filename | wc -l)

temp=$(identify -format "%[w] x %[h]\n" $filename)
initw=$(echo $temp | grep -P -o  "[0-9^\t]+" | head -n 1)
inith=$(echo $temp | grep -P -o  "[0-9^\t]+" | tail -n 1)




# Initial & Final width
finalw=$(( initw / zoom_factor ))
# Initial & Final height
finalh=$(( inith / zoom_factor ))
# Final x offset from top left
finalx=$(( x - finalw / 2 ))
# Final y offset from top left
finaly=$(( y - finalh / 2 ))

convert -coalesce $filename out%d.jpeg

# Remove anything from previous attempts
rm frame-*jpg 2> /dev/null
for i in $(seq 0 $steps); do
   ((x=finalx*i/steps))
   ((y=finaly*i/steps))
   ((w=initw-(i*(initw-finalw)/steps)))
   ((h=inith-(i*(inith-finalh)/steps)))
   echo $i,$x,$y,$w,$h
   name=$(printf "frame-%03d.jpg" $i)
   let filenumber=$(($i%$frames))
   convert out${filenumber}.jpeg -crop ${w}x${h}+${x}+${y} -resize ${initw}x${inith} "$name"
done
convert -delay $delay frame* anim.gif

convert anim.gif -coalesce -scale 200x150 -fuzz 2% +dither -remap anim.gif[0] -layers Optimize result.gif
convert -rotate 90 result.gif result1.gif
convert -rotate 180 result.gif result2.gif
convert -rotate 270 result.gif result3.gif
convert -rotate 125 result.gif result4.gif

rm frame*
rm out*