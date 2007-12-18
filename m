From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [patch 1/2] [RFC] Simple tamper-proof device filesystem.
Date: Mon, 17 Dec 2007 19:55:57 -0600
Message-ID: <20071218015557.GA28652@sergelap.austin.ibm.com>
References: <20071216080441.435456586@I-love.SAKURA.ne.jp> <20071216080628.061470932@I-love.SAKURA.ne.jp> <200712161944.HEI26071.MOtOFLVHFSQFOJ@I-love.SAKURA.ne.jp> <200712161956.BJE32406.FOOHtQJLMFOSVF@I-love.SAKURA.ne.jp> <20071217194802.GA14156@sergelap.austin.ibm.com> <200712180003.lBI03N7F092396@www262.sakura.ne.jp> <20071218003955.GA27048@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20071218003955.GA27048@sergelap.austin.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue@us.ibm.com):
> Quoting Tetsuo Handa (penguin-kernel@i-love.sakura.ne.jp):
> > Hello.
> > 
> > Serge E. Hallyn wrote:
> > > CAP_MKNOD will be removed from its capability
> > I think it is not enough because the root can rename/unlink device files
> > (mv /dev/sda1 /dev/tmp; mv /dev/sda2 /dev/sda1; mv /dev/tmp /dev/sda2).
> 
> Sure but that doesn't bother us :)
> 
> The admin in the container has his own /dev directory and can do what he
> likes with the devices he's allowed to have.  He just shouldn't have
> access to others.  If he wants to rename /dev/sda1 to /dev/sda5 that's
> his choice.
> 
> > > To use your approach, i guess we would have to use selinux (or tomoyo)
> > > to enforce that devices may only be created under /dev?
> > Everyone can use this filesystem alone.
> 
> Sure but it is worthless alone.
> 
> No?

Oh, no, I'm sorry - I was thinking in terms of my requirements again.
But your requirements are to ensure that an application accessing a
device at a well-known location get what it expect.

So then the main quesiton is still the one I think Al had asked - what
keeps a rogue CAP_SYS_MOUNT process from doing
mount --bind /dev/hda1 /dev/null ?

thanks,
-serge

> What will keep the container admin from doing 'mknod /root/hda1 b 3 1'?
> 
> > But use with MAC (or whatever access control mechanisms that prevent
> > attackers from unmounting/overlaying this filesystem) is recomennded.
> 
> -serge
