From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [cgroup or VFS ?] WARNING: at fs/namespace.c:636
	mntput_no_expire+0xac/0xf2()
Date: Mon, 16 Feb 2009 02:57:30 +0000
Message-ID: <20090216025729.GU28946@ZenIV.linux.org.uk>
References: <20090212070729.GF28946@ZenIV.linux.org.uk> <4995007D.7040101@cn.fujitsu.com> <20090213054751.GI28946@ZenIV.linux.org.uk> <49950F3D.3030704@cn.fujitsu.com> <20090213064135.GJ28946@ZenIV.linux.org.uk> <20090213071816.GK28946@ZenIV.linux.org.uk> <4995208D.8050700@cn.fujitsu.com> <4998C15C.2070203@cn.fujitsu.com> <20090216023812.GT28946@ZenIV.linux.org.uk> <4998D3A6.9010406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757099AbZBPC5r@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4998D3A6.9010406@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, gregkh@ZenIV.linux.org.uk, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Mon, Feb 16, 2009 at 10:47:02AM +0800, Li Zefan wrote:
> And here is my:
> 
> Tested-by: Li Zefan <lizf@cn.fujitsu.com>

Right...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
