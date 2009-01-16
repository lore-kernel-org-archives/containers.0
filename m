From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Performance of netns with sysfs
Date: Thu, 15 Jan 2009 20:35:28 -0800
Message-ID: <m1sknjvpf3.fsf@frodo.ebiederm.org>
References: <87ocy8thhj.fsf@caffeine.danplanet.com>
	<1232055472.6398.100.camel@groeck-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1232055472.6398.100.camel@groeck-laptop> (Guenter Roeck's
	message of "Thu, 15 Jan 2009 13:37:52 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org> writes:

> There are two key elements affecting performance when creating large
> numbers of interfaces:
> - full_name_hash() doesn't do a good job in selecting hash buckets
> - sysfs uses a linked list to store directory entries, and strcmp() to
> compare entries.
>
> The sysfs problem may be solved with Eric's sysfs upcoming changes; if
> not, there are (at least) two ways to improve sysfs performance: 

I have not addressed the slowdown problem.  But it is good to hear
that it exists and that people care.  I thought sysfs was going to
slow things down.

My immediate goal is to reduce the locking complexity to that found
within /proc.

> 1) store a name hash with each entry, and compare the hash result before
> comparing the entire name
> 2) create a per-directory hash table.
>
> full_name_hash() can be improved by replacing the hash, for example as
> follows. 
> Old:
> 	return (prevhash + (c << 4) + (c >> 4)) * 11;
> New:
> 	return (prevhash + c) * 41;

At least with the sanity checking turned on.  sysctl will also have
slowdowns that are more significant than sysfs when creating network
devices.  So that should be addressed as well.

Eric
