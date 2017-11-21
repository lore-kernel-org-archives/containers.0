From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 0/9] use network namespace for iSCSI control interfaces
Date: Tue, 21 Nov 2017 13:46:03 -0600
Message-ID: <87mv3fo1ok.fsf__18808.6671675139$1511293592$gmane$org@xmission.com>
References: <20171107180156.GD29597@straylight.hirudinean.org>
	<20171107224513.4217-1-cleech@redhat.com>
	<063D6719AE5E284EB5DD2968C1650D6DD00B618E@AcuExch.aculab.com>
	<20171115002521.GA21082@straylight.hirudinean.org>
	<687d0196888f4325aebc0989a8e12ced@AcuMS.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <687d0196888f4325aebc0989a8e12ced-1XygrNkDbNvwg4NCKwmqgw@public.gmane.org> (David
	Laight's message of "Tue, 21 Nov 2017 11:26:09 +0000")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, 'Chris Leech' <cleech-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org> writes:

> To make matters even more annoying the functions for holding and
> releasing a namespace are GPL_ONLY :-(

I am going to pick on this by itself for a moment without mentioning
anything else, so as hopefully not to derail what otherwise sounds
like a good technical conversation.

So far every time when someone has complained to me about things being
GPL_ONLY and I have looked into it, all I have seen is someone trying
to come up with a way to release derivative works of the kernel without
honoring the terms of the GPLv2.

I read through the US Code a while back to see if I could understand
what is legaly defined as a derivative work, and my impression at the
time was that the FSF is quite conservative in what they consider a
derivative work, and probably the scope is much wider.

So when people start complaining about things being GPLv2 those are the
most annoying bug reports I ever deal with, as almost invariably people
just want to take from the community and don't want to work with every
one else.

It is especially annoying because I have never seen a case where there
is a good justification for a kernel export being anything other than
GPL_ONLY.  That is the kernel's license after all, and if you are using
kernel internal functions the chance that your code is not a derivative
work is about 0.

Eric
