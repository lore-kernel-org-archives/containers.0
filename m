From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/7] proc: Implement support for automounts in task directories
Date: Thu, 06 Nov 2008 18:02:24 -0800
Message-ID: <m1fxm4xphr.fsf@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
	<20081106172521.91061dcf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753563AbYKGCF2@vger.kernel.org>
In-Reply-To: <20081106172521.91061dcf.akpm@linux-foundation.org> (Andrew
	Morton's message of "Thu, 6 Nov 2008 17:25:21 -0800")
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, adobriyan@gmail.com, viro@ZenIV.linux.org.uk, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 06 Nov 2008 02:48:35 -0800
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> This is a genearl mechanism that is capable of removing
>> any unused mounts on /proc in any directory.  As we flush
>> the mounts when a processes dies this mechanism is tailored
>> for flushing mounts in the per task and per task group
>> directories.
>
> What I'm missing here is any sense of what these patches are for,
> where they're headed, what the big picture is, etc?

Sorry.

> My vague guess is that perhaps it has something to do with mounting
> procfs multiple times in separate containers.  How did I do?

The big picture is that right now /proc/<pid>/net/stat
is a directory that is hard linked in different locations.

Which means you can deadlock rename at the vfs level
(despite the fact that proc doesn't support rename).

So this patchset splits /proc/net out into it's own filesystem
so we don't have multiple hard links.

It uses the vfs level automounts  to preserve backwards compatibility
so user space does not need to explicitly mount /proc/<pid>/net.

When Al noticed the problem there was some security drama, and
people were privately cc'd etc.  And however it works I am incompetent
at getting patches merged in that kind of environment.  So these
patches have languished since the middle of September.

On one level these patches constitute a bug fix for the bug
of having multiple hard links in /proc/net.  At another level
these patches are a clean up and a nice to have feature.  Allowing
a network namespace to be monitored in the weird interval between when
the last processes goes away and when the network namespace is destroyed.
Because you can mount /proc/net independently.

Eric
