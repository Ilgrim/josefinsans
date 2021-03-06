#!/bin/sh
set -e


echo "Generating Static fonts"
mkdir -p ../fonts
mkdir -p ../fonts/otf
mkdir -p ../fonts/ttf
mkdir -p ../fonts/vf
fontmake -m JosefinSans.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m JosefinSans.designspace -i -o otf --output-dir ../fonts/otf/
fontmake -m JosefinSans-Italic.designspace -o ttf --output-dir ../fonts/ttf/
fontmake -m JosefinSans-Italic.designspace -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
fontmake -m JosefinSans.designspace -o variable --output-path ../fonts/vf/JosefinSans[wght].ttf
fontmake -m JosefinSans-Italic.designspace -o variable --output-path ../fonts/vf/JosefinSans-Italic[wght].ttf

rm -rf master_ufo/ instance_ufo/ instance_ufos/


echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	#ttfautohint $ttf "$ttf.fix";
	#mv "$ttf.fix" $ttf;
done

vfs=$(ls ../fonts/vf/*.ttf)
echo vfs
echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	#ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
	#mv "$vf.fix" $vf;
done

echo "Fixing VF Meta"
gftools fix-vf-meta $vfs;

echo "Dropping MVAR"
for vf in $vfs
do
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/vf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fixing Hinting"
for vf in $vfs
do
	gftools fix-nonhinting $vf "$vf.fix";
	if [ -f "$vf.fix" ]; then mv "$vf.fix" $vf; fi
done

for ttf in $ttfs
do
	gftools fix-nonhinting $ttf "$ttf.fix";
	if [ -f "$ttf.fix" ]; then mv "$ttf.fix" $ttf; fi
done

rm -f ../fonts/vf/*.ttx
rm -f ../fonts/ttf/*.ttx
rm -f ../fonts/vf/*gasp.ttf
rm -f ../fonts/ttf/*gasp.ttf

echo "Done"
