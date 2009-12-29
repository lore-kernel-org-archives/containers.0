From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/4] cgroups: subsystem module loading interface
Date: Tue, 29 Dec 2009 09:03:57 +0800
Message-ID: <4B39557D.6000600__38569.1985990435$1262048784$gmane$org@cn.fujitsu.com>
References: <20091221203253.GA5683@andrew.cmu.edu>
	<20091221203613.GC5683@andrew.cmu.edu>
	<4B3850F4.4090203@cn.fujitsu.com>
	<20091228124029.GB4824@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091228124029.GB4824-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

>>> +	write_lock(&css_set_lock);
>>> +	for (i = 0; i < CSS_SET_TABLE_SIZE; i++) {
>>> +		struct css_set *cg;
>>> +		struct hlist_node *node, *tmp;
>>> +		struct hlist_head *bucket = &css_set_table[i], *new_bucket;
>> Please add a blank line between variable declaration and other code.
>>
>> And elsewhere in this patchset.
>>
> 
> checkpatch.pl didn't trip on this [and the more screenspace-intensive
> comment style]; are they cgroups-specific style requirements or from
> somewhere higher up?
> 

You'll find the comment style in Documentation/CodingStyle:

==============
The preferred style for long (multi-line) comments is:

        /*
         * This is the preferred style for multi-line
         * comments in the Linux kernel source code.
         * Please use it consistently.
         *
         * Description:  A column of asterisks on the left side,
         * with beginning and ending almost-blank lines.
         */
==============

Though the other coding style is not documented, I think it's
well accepted.

You'll hardly find code that breaks this style, say in kernel/* and
mm/*. And you can see that people pointed out this when they were
reviewing patches.

And the fact is it does make the code more readable.
