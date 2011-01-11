From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Teach cifs about network namespaces.
Date: Tue, 11 Jan 2011 14:03:23 -0800
Message-ID: <20110111220323.GM29064__4103.45425266332$1294783545$gmane$org@count0.beaverton.ibm.com>
References: <4D2BDE07.40202@parallels.com>
	<20110111071239.GL29064@count0.beaverton.ibm.com>
	<4D2C63B2.6090109@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D2C63B2.6090109-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kir-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jan 11, 2011 at 08:05:38AM -0600, Rob Landley wrote:
> On 01/11/2011 01:12 AM, Matt Helsley wrote:
> > On Mon, Jan 10, 2011 at 10:35:19PM -0600, Rob Landley wrote:
> >> From: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> >>
> >> Teach cifs about network namespaces, so mounting uses adresses and
> >> routing visible from a container rather than from init context.
> >>
> >> For a long drawn out test reproduction sequence, see:
> >>
> >>   http://landley.livejournal.com/47024.html
> >>   http://landley.livejournal.com/47205.html
> >>   http://landley.livejournal.com/47476.html
> >>
> >> Signed-off-by: Rob Landley <rlandley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> >> ---
> >>
> >>  fs/cifs/cifsglob.h |   32 ++++++++++++++++++++++++++++++++
> >>  fs/cifs/connect.c  |   22 +++++++++++++++++-----
> >>  2 files changed, 49 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
> >> index 7136c0c..86f31bb 100644
> >> --- a/fs/cifs/cifsglob.h
> >> +++ b/fs/cifs/cifsglob.h

<snip>

> >> +#ifdef CONFIG_NET_NS
> >> +#define cifs_use_net_ns() (1)
> >> +#else
> >> +#define cifs_use_net_ns() (0)
> >> +#endif
> > 
> > This looks wrong -- we shouldn't need this at all. The #ifdef bits in
> > your patch already make all the cases below become empty/no-ops when
> > CONFIG_NET_NS=n.
> 
> Except that bloat-o-meter said they were still generating code and
> making the kernel bigger.  (Things like calling get() and put() on
> init_net to twiddle its reference count.)

I think the only code that would be generated is the test discussed
below. And we're probably talking a few instructions -- an insignificant
amount. There are probably much better places to make a substantial
impact on kernel bloat.

> 
> I'm a long-time embedded programmer, I try not to make the code bigger
> than necessary, especially when we have a config symbol to remove stuff.
>  I did ponder turning those into HAVE_NET_HS so the if was more
> obviously against a constant.

My recollection is that method of doing things is often frowned upon in
kernel code. There are exceptions of course, but most use the CONFIG_FOO
patterns you've already employed (or that I already suggested).

> 
> >> +
> >> +/*
> >>   * Session structure.  One of these for each uid session with a particular host
> >>   */
> >>  struct cifsSesInfo {
> >> diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
> >> index cc1a860..b4faef0 100644
> >> --- a/fs/cifs/connect.c
> >> +++ b/fs/cifs/connect.c
> >> @@ -1545,6 +1545,10 @@ cifs_find_tcp_session(struct sockaddr *addr, struct smb_vol *vol)
> >>
> >>  	spin_lock(&cifs_tcp_ses_lock);
> >>  	list_for_each_entry(server, &cifs_tcp_ses_list, tcp_ses_list) {
> >> +		if (cifs_use_net_ns()
> >> +		    && cifs_net_ns(server) == current->nsproxy->net_ns)
> >> +			continue;
> > 
> > This looks wrong -- you want to invert part of this I think (and drop the
> > unnecessary cifs_use_net_ns()):
> 
> You're right, I got the test backwards.  Thanks.
> 
> The reason for the guards is that compiler couldn't tell that
> current->nsproxy->net_ns always contains the same value, so without a
> test against a constant allowing it to do dead code elimination, it will
> generate code to perform the useless test.

I think we're better off with simpler source code than trying to eliminate
a few instructions.

> 
> > 	if (cifs_net_ns(server) != current->nsproxy->net_ns)
> > 		continue;
> > 
> > This is obvious when you note that the context below shows that we
> > 'continue' to the next entry when the addresses don't match:
> > 
> >> +
> >>  		if (!match_address(server, addr,
> >>  				   (struct sockaddr *)&vol->srcaddr))
> >>  			continue;
> >> @@ -1572,6 +1576,9 @@ cifs_put_tcp_session(struct TCP_Server_Info *server)
> >>  		return;
> >>  	}
> >>
> >> +	if (cifs_use_net_ns())
> >> +		put_net(cifs_net_ns(server));
> >> +
> > 
> > I think this should just be:
> > 
> > 	put_net(cifs_net_ns(server));
> 
> Hmmm...  that one you're probably right, because
> include/net/net_namespace.h makes put_net() an empty inline, so as long
> as cifs_net_ns() has no side effects the compiler should be able to drop
> the whole thing out.  (Whether or not it will, I have to test...)
> 
> >>  	list_del_init(&server->tcp_ses_list);
> >>  	spin_unlock(&cifs_tcp_ses_lock);
> >>
> >> @@ -1677,6 +1684,9 @@ cifs_get_tcp_session(struct smb_vol *volume_info)
> >>  	       sizeof(tcp_ses->srcaddr));
> >>  	++tcp_ses->srv_count;
> >>
> >> +	if (cifs_use_net_ns())
> >> +		cifs_set_net_ns(tcp_ses, get_net(current->nsproxy->net_ns));
> >> +
> > 
> > Just use cifs_set_net_ns() because it already turns into a no-op when
> > CONFIG_NET_NS=n
> 
> no-op yes.  no-code, I want to make sure.  (I tried it with just the
> macros the first time through, and scripts/bloat-o-meter kept saying
> code was being generated.  I'll fire up objdump and see if the
> disassembly tells me anything...)

Yup, thanks for making sure.

<snip>

> >> @@ -2145,8 +2158,8 @@ ipv4_connect(struct TCP_Server_Info *server)
> >>  	struct socket *socket = server->ssocket;
> >>
> >>  	if (socket == NULL) {
> >> -		rc = sock_create_kern(PF_INET, SOCK_STREAM,
> >> -				      IPPROTO_TCP, &socket);
> >> +		rc = __sock_create(cifs_net_ns(server), PF_INET,
> >> +				   SOCK_STREAM, IPPROTO_TCP, &socket, 1);
> >>  		if (rc < 0) {
> >>  			cERROR(1, "Error %d creating socket", rc);
> >>  			return rc;
> >> @@ -2310,11 +2323,10 @@ ipv6_connect(struct TCP_Server_Info *server)
> >>  	struct socket *socket = server->ssocket;
> >>
> >>  	if (socket == NULL) {
> >> -		rc = sock_create_kern(PF_INET6, SOCK_STREAM,
> >> -				      IPPROTO_TCP, &socket);
> >> +		rc = __sock_create(cifs_net_ns(server), PF_INET6,
> >> +				   SOCK_STREAM, IPPROTO_TCP, &socket, 1);
> >>  		if (rc < 0) {
> >>  			cERROR(1, "Error %d creating ipv6 socket", rc);
> >> -			socket = NULL;
> >>  			return rc;
> >>  		}
> 
> Note, those two add 16 bytes each on x86-64 (two extra 8-byte
> arguments), but that I couldn't easily stop.  I might try to merge the
> ipv4/ipv6 functions, but that's a separate patch.

If anything I think you're saving more space with your patched code:

int sock_create_kern(int family, int type, int protocol, struct socket
**res)
{
        return __sock_create(&init_net, family, type, protocol, res, 1);
}
EXPORT_SYMBOL(sock_create_kern);

It's not an inline function so I expect using sock_create_kern() will take up
more stack space than calling __sock_create() directly. On some archs
the instructions to make the extra function call might also take up
'significant' space. And you're passing an 8-byte pointer *anyway* so no size
difference there unless the compiler is more clever than I expect.

In my humble opinion you don't need to spend so much time counting bytes
:). 

Cheers,
	-Matt
