love: build/vrrTest.love
build/vrrTest.love: src/colorFade.lua src/conf.lua src/main.lua src/run.lua src/scenes src/gamepad.lua src/lines.lua
	cd src ; zip -r ../build/vrrTest.love colorFade.lua conf.lua main.lua run.lua scenes gamepad.lua lines.lua

win: build/vrrTest.love build/win/vrrTest-win-x86_64.zip build/win/love.exe
build/win/vrrTest-win-x86_64.zip:
	cat build/win/love.exe build/vrrTest.love > build/win/vrrTest.exe
	cd build ; zip -j -r vrrTest-win-x86_64.zip win/love.dll win/love.ico win/lua51.dll win/mpg123.dll win/msvcp120.dll win/msvcr120.dll win/OpenAL32.dll win/SDL2.dll win/vrrTest.exe

lin: build/vrrTest.love build/lin/squashfs-root/
	cat build/lin/squashfs-root/bin/love build/vrrTest.love > build/lin/squashfs-root/bin/vrrTest
	chmod +x build/lin/squashfs-root/bin/vrrTest
	rm build/lin/squashfs-root/bin/love
	cp dist/vrrtest.desktop build/lin/squashfs-root/love.desktop
	cp dist/vrrtest.svg build/lin/squashfs-root/vrrtest.svg
	rm build/lin/squashfs-root/love.svg
	cp dist/AppRun build/lin/squashfs-root/
	appimagetool build/lin/squashfs-root build/vrrTest.AppImage

clean:
	-rm build/vrrTest.love build/win/vrrTest-win-x86_64.zip build/lin/vrrTest-x86_64.AppImage

.PHONY: win love clean lin
