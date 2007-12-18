From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [patch 1/2] [RFC] Simple tamper-proof device filesystem.
Date: Tue, 18 Dec 2007 12:40:25 +0900
Message-ID: <200712180340.lBI3eQk3039357@www262.sakura.ne.jp>
References: <20071216080441.435456586@I-love.SAKURA.ne.jp> <20071216080628.061470932@I-love.SAKURA.ne.jp> <200712161944.HEI26071.MOtOFLVHFSQFOJ@I-love.SAKURA.ne.jp> <200712161956.BJE32406.FOOHtQJLMFOSVF@I-love.SAKURA.ne.jp> <20071217194802.GA14156@sergelap.austin.ibm.com> <200712180003.lBI03N7F092396@www262.sakura.ne.jp> <20071218003955.GA27048@sergelap.austin.ibm.com> <20071218015557.GA28652@sergelap.austin.ibm.com> <200712180226.lBI2QL1d020811@www262.sakura.ne.jp> <20071218025329.GA12429@vino.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20071218025329.GA12429@vino.hallyn.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: serge@hallyn.com
Cc: "\"\\\"Serge E. Hallyn\\\"\"" <serue@us.ibm.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hello.

Serge E. Hallyn wrote:
> Nope, try
> 
>   touch /root/hda1
>   ls -l /root/hda1
>   mount --bind /dev/hda1 /root/hda1
>   ls -l /root/hda1

[root@sakura ~]# touch /root/hda1
[root@sakura ~]# ls -l /root/hda1
-rw-r--r-- 1 root root 0 Dec 18 12:04 /root/hda1
[root@sakura ~]# mount --bind /dev/hda1 /root/hda1
[root@sakura ~]# ls -l /root/hda1
brw-r----- 1 root disk 3, 1 Dec 18  2007 /root/hda1

Oh, surprising.
I didn't know mount() accepts non-directory for mount-point.
But I think this is not a mount operation
because I can't see the contents of /dev/hda1 through /root/hda1 .
Can I see the contents of /dev/hda1 through /root/hda1 ?


> Then it sounds like this filesystem is something Tomoyo can use.

I had / partition mounted for read-only so that the admin can't do
'mknod /root/hda1 b 3 1' in 2003, and I named it
"Security Advancement Know-how Upon Readonly Approach for Linux" or SAKURA Linux.
This filesystem (SYAORAN) is developed to make /dev writable and tamper-proof
when / partition is read-only or protected by MAC.
TOMOYO is a pathname-based MAC implementation, and
SAKURA and SYAORAN were merged into TOMOYO Linux. ;-)

Regards.
