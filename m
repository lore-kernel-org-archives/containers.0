From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Tue, 23 Feb 2010 06:07:32 -0800
Message-ID: <m1iq9ocafv.fsf__36883.4050292664$1266934201$gmane$org@fess.ebiederm.org>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266931623.3973.643.camel@bigi> (jamal's message of "Tue\,
	23 Feb 2010 08\:27\:03 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Cc: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> writes:

> On Mon, 2010-02-22 at 15:17 -0800, Eric W. Biederman wrote:
>
>> What I am thinking is:
>> 
>> "ip ns <name> route add blah" is:
>> fd = open("/var/run/netns/<name>");
>> sys_setns(fd);  /* Like unshare but takes an existing namespace */
>> /* Then the rest of the existing ip command */
>
> The other two below make some sense; For the above:
> Does the point after sys_setns(fd) allow me to do io inside
> ns <name>? Can i do open() and get a fd from ns <name>?

Yes.  My intention is that current->nsproxy->net_ns be changed.
We can already change it in unshare so this is feasible.

>> "ip ns list" is:
>> dfd = open("/var/run/netns", O_DIRECTORY);
>> getdents(dfd, buf, count);
>> 
>> "ip ns new <name>" is:
>> unshare(CLONE_NEWNS);
>> fd = nsfd(NETNS);
>> mkdir("/var/run/netns/<name>");
>> mount("none", "/var/run/netns/<name>", "ns", 0, fd);
>> 
>> Using unix domain names means that which namespaces you see is under
>> control of userspace.  Which allows for nested containers (something I
>> use today), and ultimately container migration.
>
> The only problem that i see is events are not as nice. I take it i am 
> going to get something like an inotify when a new namespace is created?

Yes.  Inotify would at the very least see that mkdir.  You could also
use poll on /proc/mounts to see the set of mounts change.

>> Using genetlink userspace doesn't result in a nestable implementation
>> unless I introduce yet another namespace, ugh.
>
> Is it not just a naming convention that you are dealing with?
> Example in your scheme above a nested namespace shows up as:
> /var/run/netns/<name>/<nestedname>, no?

No.  More like:

For the outer namespace:
/var/run/netns/<name>

For the inner namespace:
/some/random/fs/path/to/a/chroot/var/run/netns/<name>

For a doubly nested scenario:
/some/random/fs/path/to/a/chroot/some/other/random/fs/path/to/another/chroot/var/run/netns/<name>

Since I would be using mount namespaces instead of chroot it is not
strictly required that the fs paths nest at all.

Eric
