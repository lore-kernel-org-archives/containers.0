From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/7] proc: Implement support for automounts in task directories
Date: Thu, 06 Nov 2008 18:05:46 -0800
Message-ID: <m1abccxpc5.fsf@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
	<20081106172617.dd51d0af.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751396AbYKGCPq@vger.kernel.org>
In-Reply-To: <20081106172617.dd51d0af.akpm@linux-foundation.org> (Andrew
	Morton's message of "Thu, 6 Nov 2008 17:26:17 -0800")
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, adobriyan@gmail.com, viro@ZenIV.linux.org.uk, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 06 Nov 2008 02:48:35 -0800
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> +void proc_shrink_automounts(void)
>> +{
>> +	struct list_head *list = &proc_automounts;
>> +
>> +	mark_mounts_for_expiry(list);
>> +	mark_mounts_for_expiry(list);
>
> Strange.  In case the first attempt didn't work?

Yes.  I'd like to say.  Mount just go away but it takes two passes before
a mount is actually removed.

For NFS which does the whole expiry of all inodes where it comes from it
is a good fit.  For /proc where we don't have to guess it isn't the best
fit but it isn't shabby either.

>
>> +	if (list_empty(list))
>> +		return;
>> +
>> +	schedule_delayed_work(&proc_automount_task, proc_automount_timeout);
>> +}


Eric
