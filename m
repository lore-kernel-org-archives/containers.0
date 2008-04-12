From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Multiple instances of devpts
Date: Sat, 12 Apr 2008 11:54:59 -0700
Message-ID: <48010583.3020403@zytor.com>
References: <20080412172933.GA19295@us.ibm.com> <20080412183514.GO9785@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757959AbYDLSzb@vger.kernel.org>
In-Reply-To: <20080412183514.GO9785@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: sukadev@us.ibm.com, Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, matthltc@us.ibm.com, "Eric W. Biederman" <ebiederm@xmission.com>, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: containers.vger.kernel.org

Al Viro wrote:
> 
> *boggle*
> 
> Care to explain how that "namespace" is different from devpts instance?
> IOW, why the devil do you guys ignore Occam's Razor?
> 
> Frankly, this nonsense has gone far enough; I can buy the need to compensate
> for shitty APIs (sockets, non-fs-based-IPC, etc.), but devpts *is* *a*
> *fucking* *filesystem*.  Already.  And as such it's already present in
> normal, real, we-really-shouldn't-have-any-other-if-not-for-ancient-stupidity
> namespace.
> 
> Why not simply allow independent instances of devpts and be done with that?

In particular:

/dev/ptmx can be a symlink ptmx -> pts/ptmx, and we add a ptmx instance 
inside the devpts filesystem.  Each devpts filesystem is responsible for 
its own pool of ptys, with own numbering, etc.

This does mean that entries in /dev/pts are more than just plain device 
nodes, which they are now (you can cp -a a device node from /dev/pts 
into another filesystem and it will still "just work"), but I doubt this 
actually matters to anyone.  If anyone cares, now I guess would be a 
good time to speak up.

	-hpa
