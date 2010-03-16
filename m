From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] block: make CONFIG_BLK_CGROUP visible
Date: Tue, 16 Mar 2010 09:53:46 -0400
Message-ID: <20100316135346.GB9144@redhat.com>
References: <4B9DA6F5.3070606@cn.fujitsu.com> <20100315132149.GA21127@redhat.com> <4B9EE0A9.5010901@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B9EE0A9.5010901@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Gui Jianfeng <GuiJianfeng@cn.fujitsu.com>, Ben Blum <bblum@andrew.cmu.edu>, LKML <linux-kernel@vger.kernel.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 16, 2010 at 09:36:41AM +0800, Li Zefan wrote:
> >>  	---help---
> >>  	Generic block IO controller cgroup interface. This is the common
> >> @@ -91,7 +92,7 @@ config BLK_CGROUP
> >>  	to such task groups.
> >>  
> >>  config DEBUG_BLK_CGROUP
> >> -	bool
> >> +	bool "Block cgroup debugging help"
> > 
> > 
> > Why are you making DEBUG_BLK_CGROUP this as a user visible/configurable
> > option? This is already controlled by DEBUG_CFQ_IOSCHED. If you don't want
> > the DEBUG overhead, just set DEBUG_CFQ_IOSCHED=n and DEBUG_BLK_CGROUP will
> > not be selected? Making it user visible does not seem to be buying us
> > anything?
> > 
> 
> Sounds reasonable. A minor question, since DEBUG_BLK_CGROUP is not
> visible, the help message for this config is not visible too, so we
> still keep it?

Right now the message is only for developer if somebody opens the Kconfig
file. I think it does not harm if somebody wants to understand what this
config option is doing. But if you think that it should not be there, I have
no strong opinion about it.

Thanks
Vivek
