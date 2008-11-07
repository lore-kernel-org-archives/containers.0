From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/7] proc: Implement support for automounts in task
 directories
Date: Thu, 6 Nov 2008 17:26:17 -0800
Message-ID: <20081106172617.dd51d0af.akpm@linux-foundation.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752683AbYKGB1N@vger.kernel.org>
In-Reply-To: <m1abcd2kqk.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, adobriyan@gmail.com, viro@ZenIV.linux.org.uk, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

On Thu, 06 Nov 2008 02:48:35 -0800
ebiederm@xmission.com (Eric W. Biederman) wrote:

> +void proc_shrink_automounts(void)
> +{
> +	struct list_head *list = &proc_automounts;
> +
> +	mark_mounts_for_expiry(list);
> +	mark_mounts_for_expiry(list);

Strange.  In case the first attempt didn't work?

> +	if (list_empty(list))
> +		return;
> +
> +	schedule_delayed_work(&proc_automount_task, proc_automount_timeout);
> +}
