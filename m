From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Tue, 23 Feb 2010 09:20:17 -0500
Message-ID: <1266934817.3973.654.camel__45765.4349193492$1266935047$gmane$org@bigi>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	<4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	<4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	<m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	<m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	<m1iq9ocafv.fsf@fess.ebiederm.org>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1iq9ocafv.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Added Daniel to the discussion..

On Tue, 2010-02-23 at 06:07 -0800, Eric W. Biederman wrote:
> jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> writes:

> > Does the point after sys_setns(fd) allow me to do io inside
> > ns <name>? Can i do open() and get a fd from ns <name>?
> 
> Yes.  My intention is that current->nsproxy->net_ns be changed.
> We can already change it in unshare so this is feasible.

I like it if it makes it as easy as it sounds;-> With lxc,
i essentially have to create a proxy process inside the
namespace that i use unix domain to open fds inside the ns.
Do i still need that?

> > The only problem that i see is events are not as nice. I take it i am 
> > going to get something like an inotify when a new namespace is created?
> 
> Yes.  Inotify would at the very least see that mkdir.  You could also
> use poll on /proc/mounts to see the set of mounts change.

It is not as nice but livable. I suppose attributes of the specific
namespace are retrieved somewhere there as well..

> > Is it not just a naming convention that you are dealing with?
> > Example in your scheme above a nested namespace shows up as:
> > /var/run/netns/<name>/<nestedname>, no?
> 
> No.  More like:
> 
> For the outer namespace:
> /var/run/netns/<name>
> 
> For the inner namespace:
> /some/random/fs/path/to/a/chroot/var/run/netns/<name>
> 
> For a doubly nested scenario:
> /some/random/fs/path/to/a/chroot/some/other/random/fs/path/to/another/chroot/var/run/netns/<name>
> 
> Since I would be using mount namespaces instead of chroot it is not
> strictly required that the fs paths nest at all.

Ok.

cheers,
jamal
