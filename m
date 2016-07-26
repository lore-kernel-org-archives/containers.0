From: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Subject: Re: [Ksummit-discuss] [TECH TOPIC] Containerisation, namespaces and
	keyrings
Date: Tue, 26 Jul 2016 10:16:44 -0400
Message-ID: <1469542604.4212.14.camel@HansenPartnership.com>
References: <15842.1469185302@warthog.procyon.org.uk>
	<1469199065.2382.21.camel@HansenPartnership.com>
	<6125585.ae3bRTRs05@avalon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6125585.ae3bRTRs05@avalon>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>, ksummit-discuss-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
Cc: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ikent-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2016-07-26 at 16:38 +0300, Laurent Pinchart wrote:
> > Actually, I really think this isn't a KS issue, it should be 
> > proposed for the Plumbers Containers MC:
> > 
> > http://www.linuxplumbersconf.org/2016/ocw/events/LPC2016/tracks/519
> > 
> > You have all the correct people in that session.  At KS you'll have 
> > 50% bored, 48% hostile because they hate cgroups and 2% interested.
> 
> Virtualization is increasingly affecting more and more subsystems. 
> While I don't disagree with you, I also see value in teaching 
> maintainers about containers, namespaces and the way they affect
> subsystems.

I'm certainly not averse to that.  However, the proposal was to discuss
a really esoteric feature, namely keyring namespaces.  I'm just
pointing out that KS isn't the right audience to have that discussion.

>  We should ensure that best practices can be followed going forward, 
> and avoiding subsystems being developed in a way that will make it 
> difficult for them to be virtualized later (although one might argue 
> that we've already made a mess in several subsystems anyway). KS 
> would be a good place to spread the message as widely as possible 
> among maintainers, with Plumbers a good venue for more technical
> discussions.

Hey, give us brownie points for already avoiding the KVM/Xen mess.  We
do only have one API set that every container orchestration system (be
it docker, formerly known as rocket, lxc or openvz) uses.  However,
you're right, we should discuss some of the proliferation problems of
the APIs, however I'm still not convinced that KS would have the right
audience for that ...

James
