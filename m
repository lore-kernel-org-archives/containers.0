From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/8] CGroup Files: Move the release_agent file to use
	typed handlers
Date: Tue, 24 Jun 2008 16:30:35 -0700
Message-ID: <6599ad830806241630k33516715x7440e14ed6026fed__41688.4642946117$1214350446$gmane$org@mail.gmail.com>
References: <20080620234358.182933000@menage.corp.google.com>
	<20080621000730.255258000@menage.corp.google.com>
	<20080624162325.005c87e0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080624162325.005c87e0.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 24, 2008 at 4:23 PM, Andrew Morton
<akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>> +/**
>> + * cgroup_lock_live_group - take cgroup_mutex and check that cgrp is alive.
>> + * @cgrp: the cgroup to be checked for liveness
>> + *
>> + * Returns true (with lock held) on success, or false (with no lock
>> + * held) on failure.
>> + */
>> +int cgroup_lock_live_group(struct cgroup *cgrp)
>> +{
>> +     mutex_lock(&cgroup_mutex);
>> +     if (cgroup_is_removed(cgrp)) {
>> +             mutex_unlock(&cgroup_mutex);
>> +             return false;
>> +     }
>> +     return true;
>> +}
>
> I think that if we're going to do this it would be nice to add a
> symmetrical cgroup_unlock_live_group()?

There's already a cgroup_unlock() function exported in cgroup.h -
that's the counterpart to both cgroup_lock() and
cgroup_lock_live_group(). I can add a comment about this in the docs
for cgroup_lock_live_cgroup().


>
> Because code like this:
>
>> +     if (!cgroup_lock_live_group(cgrp))
>> +             return -ENODEV;
>> +     strcpy(cgrp->root->release_agent_path, buffer);
>> +     mutex_unlock(&cgroup_mutex);
>
> is a bit WTFish, no?  it forces each caller of cgroup_lock_live_group()
> to know about cgroup_lock_live_group() internals.

cgroup_mutex isn't directly exported outside of cgroup.c, so real
callers would have no choice but to use cgroup_unlock() in this
instance. I guess it could make sense to be consistent and use
cgroup_unlock() within cgroup.c as well.

Paul
