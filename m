From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [cgroup or VFS ?]  WARNING: at fs/namespace.c:636
	mntput_no_expire+0xac/0xf2()
Date: Mon, 9 Feb 2009 11:03:48 +0000
Message-ID: <20090209110348.GV28946@ZenIV.linux.org.uk>
References: <49617D35.4040805@cn.fujitsu.com> <20090209004046.3ce1dde0.akpm@linux-foundation.org> <498FEE24.5030407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754851AbZBILEG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <498FEE24.5030407@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, containers@lists.osdl.org, Arjan van de Ven <arjan@infradead.org>
List-Id: containers.vger.kernel.org

	BTW, a trivial note - kfree(root) in your ->kill_sb() is done
earlier than it's nice to do.  Shouldn't affect the problem, though.
