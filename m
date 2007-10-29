From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] pidns: Limit kill -1 and cap_set_all
Date: Mon, 29 Oct 2007 12:07:29 -0600
Message-ID: <m1d4uxpzfi.fsf@ebiederm.dsl.xmission.com>
References: <m1y7dp22d4.fsf@ebiederm.dsl.xmission.com>
	<alpine.LFD.0.999.0710261105440.30120@woody.linux-foundation.org>
	<m1r6jhzmov.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5p9zk6b.fsf_-_@ebiederm.dsl.xmission.com>
	<47259BE9.4050904@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759620AbXJ2SI6@vger.kernel.org>
In-Reply-To: <47259BE9.4050904@openvz.org> (Kirill Korotaev's message of "Mon,
	29 Oct 2007 11:38:01 +0300")
Sender: linux-kernel-owner@vger.kernel.org
To: Kirill Korotaev <dev@openvz.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@tv-sign.ru>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Kirill Korotaev <dev@openvz.org> writes:

> I dislike this patch:
> it's not scalable/efficient to travers all the tasks
> while we know the pid namespace we care about.

Well the unix way is to implement it simple and stupid and then to
optimize, where needed.  We don't currently have a per pid namespace
list of processes or tasks.

This is a trivial bug fix patch, and I wanted the review to be as
simple as possible.

I don't expect people are doing kill -1 all that frequently as it is a
bit rude.

I have no problem doing find_ge_pid and then looking in the hash table
like we do in /proc.  It likely will have fewer conflicts, but that
is a bit harder to review, and is actually more code.

Eric
