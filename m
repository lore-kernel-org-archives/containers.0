From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] lost content of /proc/sys/fs/binfmt_misc
Date: Thu, 06 Dec 2007 03:17:16 -0700
Message-ID: <m1fxygt9eb.fsf@ebiederm.dsl.xmission.com>
References: <20071205143518.GA24886@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753238AbXLFKS7@vger.kernel.org>
In-Reply-To: <20071205143518.GA24886@iris.sw.ru> (Denis V. Lunev's message of
	"Wed, 5 Dec 2007 17:35:18 +0300")
Sender: linux-kernel-owner@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Cc: akpm@linux-foundation.org, marcus@better.se, containers@lists.osdl.org, devel@openvz.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den@openvz.org> writes:

> /proc/sys/fs/binfmt_misc dentry disappeared during d_revalidate.
> d_revalidate only dentries from shadowed one and below.
> http://bugzilla.kernel.org/show_bug.cgi?id=9504

Denis this is decent except it doesn't completely close the possibility of
leaking mounts.  It just refuses to leak mounts on everything except /proc/net.

Eric
