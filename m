From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/7] proc: Implement support for automounts in task
 directories
Date: Thu, 6 Nov 2008 20:28:22 -0800
Message-ID: <20081106202822.a1af8a6e.akpm@linux-foundation.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
	<20081106172617.dd51d0af.akpm@linux-foundation.org>
	<m1abccxpc5.fsf@frodo.ebiederm.org>
	<20081106184945.179c248a.akpm@linux-foundation.org>
	<m1iqr0urb8.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755220AbYKGE3G@vger.kernel.org>
In-Reply-To: <m1iqr0urb8.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, adobriyan@gmail.com, viro@ZenIV.linux.org.uk, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, 06 Nov 2008 19:51:23 -0800 ebiederm@xmission.com (Eric W. Biederman) wrote:

> If we could do all of this with reference counting so that the
> mount would persist exactly until the last user of it has gone
> away without a periodic poll I would love it.  But the infrastructure
> doesn't support that today,

Well that sucks.  The free-on-last-put idiom occurs in so many places
and serves us so well.  I wonder what went wrong here?

I guess it has interactions with dentry and inode cache aging which
could get tricky.

> and where this is at least partially
> a bug fix I would rather not have the change depend on enhancing
> the VFS.
> 
> The algorithm is actually very aggressive and in practice you don't
> see any /proc/<pid>/net showing up as a mount point.

Do you think it has failure modes?  Most particularly: obscure usage
patterns which can cause memory exhaustion?

> > Obviously, that becomes clearer as one spends more time with the code,
> > but I wonder whether this has all been made as maintainble as it
> > possibly could be.
> 
> Good question.
> 
> In the sense of will we have to go through and futz with the code all
> of the time.  The abstraction seems good.   You put a mount on
> the proc_automounts list with do_add_mounts and it goes away eventually
> with all of the vfs rules maintained.
> 
> In the sense of can the code be read?    Perhaps it could be better.
> I expect it helps to have run the code and see /proc/net as a filesystem.
> that is magically mounted.

'twould be a useful contribution if you were to enshrine your
discoveries in /*these things*/.  You knew I was working up to that :)
