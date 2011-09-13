From: Andrew Morton <akpm@google.com>
Subject: Re: [PATCH 00/11 v5] cgroups: Task counter subsystem
Date: Tue, 13 Sep 2011 15:23:02 -0700
Message-ID: <20110913152302.6c33ea6d.akpm@google.com>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <paul@paulmenage.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>, Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Tue, 13 Sep 2011 01:11:20 +0200
Frederic Weisbecker <fweisbec@gmail.com> wrote:

> No functional changes. Only documentation and comments added.
> Checkpatch.pl fixes, etc...
> 

What is the actual rationale for merging all of this?  For this amount
of complexity I do think we need to see significant end-user benefits. 
But all I'm seeing in this patchset is

       This is a step to be able to isolate a bit more a cgroup
       against the rest of the system and limit the global impact of a
       fork bomb inside a given cgroup.

which is really very thin.



Also, the changelogs don't appear to mention any testing results for
the fork-bomb-killer feature.

Is the fork-bomb-killer feature realistically useful?  As I understand
it, the problem with a fork-bomb is that it causes a huge swapstorm
while creating tasks very quickly.  The latency impact of the swapping
makes it very hard to regain control of the system so you can stop the
forking.  So to be effective, this feature would need to limit the
swapping?  Or something.  More substantiation, please.



Also, what is the relationship between this and RLIMIT_NPROC?  Given
that we have user namespaces, does that give us per-user,
per-namespace, per-container rlimits?  If it doesn't, should it?  Will
it?  If it does/will, how duplicative will that be?
