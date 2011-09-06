From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
 directory v6
Date: Tue, 6 Sep 2011 14:15:18 +0400
Message-ID: <20110906101518.GA4799@albatros>
References: <20110831112642.GI25465@sun>
 <20110831140416.GA17626@shutemov.name>
 <20110831142622.GB30615@sun>
 <20110831151023.5b7e12da.akpm@linux-foundation.org>
 <20110901080508.GF30615@sun>
 <20110902163711.GA3124@albatros>
 <20110905185358.GA2103@albatros>
 <20110905192009.GJ761@sun>
 <20110905194908.GA2690@albatros>
 <20110905203627.GL761@sun>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110905203627.GL761@sun>
Sender: linux-fsdevel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Nathan Lynch <ntl@pobox.com>, kernel-hardening@lists.openwall.com, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Glauber Costa <glommer@parallels.com>, James Bottomley <jbottomley@parallels.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Al Viro <viro@ZenIV.linux.org.uk>, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On Tue, Sep 06, 2011 at 00:36 +0400, Cyrill Gorcunov wrote:
> > But I still see one very nasty issue - one may trigger this ptrace check,
> > trigger d_drop() and then look at /proc/slabinfo at "dentry" row.  If
> > the number has changed, then the interested dentry existed before the
> > revalidate call.  This infoleak is tricky to fix without any race.
> > 
> > Probably it's time to close /proc/slabinfo infoleak? 
> > 
> 
> Actually I miss to see how exactly this infoleak can be used by attacker
> or whoever. So, Vasiliy, what the security issue there?

The security model of procfs is: /proc/PID/fd/ is available to users
that may ptrace PID only.  Particularly, the number of opened file
descriptors is a private information.  If other task that may not ptrace
PID is able to get this information, this is an issue.  Keeping opened
file descriptor of /proc/PID/fd/ and exec'ing some setxid binary as PID
might lead to the infoleak.  It can be used in certain rare cases when
the knowledge of whether specific fd is opened/closed gains some
important information, e.g. whether some security check has
failed/succeeded (which is indirectly signaled by the kept fd).  As for
map_files/ it may reveal ASLR offsets (but only some bits, not all of
them, I guess).

Without dropping denries it can be identified by calling stat() or
link() against dentries existing in the cache.  In more details:

1) an attacker has a task with pid=PID with many opened fds.

2) Other task (PID2) opens /proc/PID/fd/ and fills the dentry cache.
Now dcache contains procfs entries for file descriptors of PID.

3) PID execve's setxid binary.  (From this point PID2 should not get
_any_ information about /proc/PID/fd/, but this rule is violated in (4).)

4) PID2 does something to learn whether any fd of PID is opened/closed.

  a) before "proc: fix races against execve() of /proc/PID/fd**" patch
     PID2 could simply do getdents() against kept file descriptor of
     /proc/PID/fd and get the list of opened fds.

  b) Without dentry dropping on each access PID2 could use link(2) to
     read /proc/PID/fd/* dentries from dcache.  As they are in the
     dcache since (2), ptrace check from ->lookup() is not applied.

  c) If dentry is lazily dropped on each access attempt (or each illegal
     access) then PID2 can:

     i) read dentry line of /proc/slabinfo
     ii) call link(2) against /proc/PID/fd, which invalidates the
         specific dentry
     iii) re-read dentry line of /proc/slabinfo.  If it has decreased by
         one, the dentry existed before (ii).


Is it possible to either allocate already dropped dentry or to force
->lookup() without invalidating dentry?  The latter would potentially
pollute the dchache, though.


Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
