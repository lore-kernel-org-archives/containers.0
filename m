From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Subject: Re: [patch 1/2] [RFC] Simple tamper-proof device filesystem.
Date: Tue, 18 Dec 2007 11:26:21 +0900
Message-ID: <200712180226.lBI2QL1d020811@www262.sakura.ne.jp>
References: <20071216080441.435456586@I-love.SAKURA.ne.jp> <20071216080628.061470932@I-love.SAKURA.ne.jp> <200712161944.HEI26071.MOtOFLVHFSQFOJ@I-love.SAKURA.ne.jp> <200712161956.BJE32406.FOOHtQJLMFOSVF@I-love.SAKURA.ne.jp> <20071217194802.GA14156@sergelap.austin.ibm.com> <200712180003.lBI03N7F092396@www262.sakura.ne.jp> <20071218003955.GA27048@sergelap.austin.ibm.com> <20071218015557.GA28652@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20071218015557.GA28652@sergelap.austin.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: "\"\\\"Serge E. Hallyn\\\"\"" <serue@us.ibm.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Hello.

Serge E. Hallyn wrote:
> But your requirements are to ensure that an application accessing a
> device at a well-known location get what it expect.

Yes. That's the purpose of this filesystem.


> So then the main quesiton is still the one I think Al had asked - what
> keeps a rogue CAP_SYS_MOUNT process from doing
> mount --bind /dev/hda1 /dev/null ?

Excuse me, but I guess you meant "mount --bind /dev/ /root/" or something
because mount operation requires directories.
MAC can prevent a rogue CAP_SYS_MOUNT process from doing
"mount --bind /dev/ /root/".
For example, regarding TOMOYO Linux, you need to give
"allow_mount /dev/ /root/ --bind 0" permission
to permit "mount --bind /dev/ /root/" request.

Did you mean "ln -s /dev/hda1 /dev/null" or "ln /dev/hda1 /dev/null"?
No problem. MAC can prevent such requests too.

Regards.
