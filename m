From: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH/RFC] user_ns: fix missing limiting of user_ns counts
Date: Sun, 30 Dec 2012 15:00:40 +0400
Message-ID: <20121230110040.GA4351@cachalot>
References: <20121228175627.GA7683@cachalot>
 <87wqw15wqb.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87wqw15wqb.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 28, 2012 at 20:05 -0800, Eric W. Biederman wrote:
> > A related issue which is NOT FIXED HERE is limits for all resources
> > available for containerized pseudo roots.  E.g. I succeeded creating
> > thousands of veth network devices without problems by a non-root user,
> > there seems no limit in number of network devices.  I suspect it is
> > possible to setup routing and net_ns'es the way it will be very
> > time-consuming for kernel to handle IP packets inside of ksoftirq, which
> > is not counted as this user scheduler time.   I suppose the issue is not
> > veth-specific, almost all newly available for unprivileged users code
> > pathes are vulnerable to DoS attacks.
> 
> veth at least should process packets synchronously so I don't see how
> you will get softirq action.

What do you mean -- synchronously?  From my limited understanding of
veth job, it is handled like every network packet in system, via:

    veth_xmit() -> dev_forward_skb() -> netif_rx() -> enqueue_to_backlog()

enqueue_to_backlog() adds the packet to softnet_data->input_pkt_queue. 

Then inside of softirq process_backlog() moves ->input_pkt_queue to
->process_queue and calls __netif_receive_skb(), which does all networking
stack magic.

AFAICS, one could create user_ns, net_ns inside of it, and setup routing
tables and netfilter to infinitely pass few network packets from and to
veth, abusing ksoftirq.

-- 
Vasily Kulikov
http://www.openwall.com - bringing security into open computing environments
