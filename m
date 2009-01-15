From: Guenter Roeck <groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Performance of netns with sysfs
Date: Thu, 15 Jan 2009 13:37:52 -0800
Message-ID: <1232055472.6398.100.camel@groeck-laptop>
References: <87ocy8thhj.fsf@caffeine.danplanet.com>
Reply-To: groeck-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ocy8thhj.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

There are two key elements affecting performance when creating large
numbers of interfaces:
- full_name_hash() doesn't do a good job in selecting hash buckets
- sysfs uses a linked list to store directory entries, and strcmp() to
compare entries.

The sysfs problem may be solved with Eric's sysfs upcoming changes; if
not, there are (at least) two ways to improve sysfs performance: 
1) store a name hash with each entry, and compare the hash result before
comparing the entire name
2) create a per-directory hash table.

full_name_hash() can be improved by replacing the hash, for example as
follows. 
Old:
	return (prevhash + (c << 4) + (c >> 4)) * 11;
New:
	return (prevhash + c) * 41;

Guenter

On Thu, 2009-01-15 at 12:57 -0800, Dan Smith wrote:
> There has been some discussion lately about network namespaces and the
> interaction with sysfs.  With the introduction of Guenter's ipcgroup
> patches, there was also the question of how feasible it is to create
> thousands of network namespaces.  So, I decided to see if I could even
> create thousands of veth pairs, and if so move them into thousands of
> network namespaces.  I was pleased to see that the system didn't fall
> over, but found that the process slowed significantly with higher
> numbers if sysfs was enabled.  I thought it would be prudent to post
> some numbers.
> 
> I first tested creating 1000 and 2500 veth pairs, attaching one side
> to a bridge with and without sysfs.  Next I created 2500 network
> namespaces, along with 2500 veth pairs.  One side of each pair was
> attached to a bridge and the other was moved into the namespace.  The
> results are:
> 
>   1000 veth pairs:        8x slower with CONFIG_SYSFS
>   2500 veth pairs         4.5x slower
>   2500 netns, veth pairs: 6x slower
> 
> The tests were done with hal disabled, attaching every third veth
> device to a different bridge (to overcome the limit of 1023 taps per
> bridge).
> 
> --
> Dan Smith
> IBM Linux Technology Center
> email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
> 
