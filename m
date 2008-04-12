From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 0/4] Helper patches for PTY namespaces
Date: Sat, 12 Apr 2008 19:35:14 +0100
Message-ID: <20080412183514.GO9785@ZenIV.linux.org.uk>
References: <20080412172933.GA19295@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757199AbYDLSgE@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080412172933.GA19295@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@us.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, serue@us.ibm.com, matthltc@us.ibm.com, "Eric W. Biederman" <ebiederm@xmission.com>, hpa@zytor.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Sat, Apr 12, 2008 at 10:29:33AM -0700, sukadev@us.ibm.com wrote:
> 
> Some simple helper patches to enable implementation of multiple PTY
> (or device) namespaces.
> 
> 	[PATCH 1/4]: Propagate error code from devpts_pty_new
> 	[PATCH 2/4]: Factor out PTY index allocation
> 	[PATCH 3/4]: Move devpts globals into init_pts_ns
> 	[PATCH 3/4]: Enable multiple mounts of /dev/pts
> 
> This patchset is based on earlier versions developed by Serge Hallyn
> and Matt Helsley.

*boggle*

Care to explain how that "namespace" is different from devpts instance?
IOW, why the devil do you guys ignore Occam's Razor?

Frankly, this nonsense has gone far enough; I can buy the need to compensate
for shitty APIs (sockets, non-fs-based-IPC, etc.), but devpts *is* *a*
*fucking* *filesystem*.  Already.  And as such it's already present in
normal, real, we-really-shouldn't-have-any-other-if-not-for-ancient-stupidity
namespace.

Why not simply allow independent instances of devpts and be done with that?
