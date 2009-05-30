From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 19:08:53 -0400
Message-ID: <1243724933.3966.158.camel__23812.2209710584$1243725080$gmane$org@dogo.mojatatu.com>
References: <20090529225929.GD2753@ami.dom.local>
	<b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	<20090530114506.GA3166@ami.dom.local>
	<1243684594.3966.89.camel@dogo.mojatatu.com>
	<20090530120750.GB3166@ami.dom.local>
	<1243686683.3966.117.camel@dogo.mojatatu.com>
	<20090530124554.GC3166@ami.dom.local>
	<1243688628.3966.126.camel@dogo.mojatatu.com>
	<20090530132047.GD3166@ami.dom.local>
	<1243690297.3966.135.camel@dogo.mojatatu.com>
	<20090530140006.GE3166@ami.dom.local>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090530140006.GE3166-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, 2009-05-30 at 16:00 +0200, Jarek Poplawski wrote:
> On Sat, May 30, 2009 at 09:31:37AM -0400, jamal wrote:
> > What were you suggesting to change in cls_group to avoid this oops?
> 
> I think checking the head (tp->root) for NULL like in cls_fw or
> cls_route should work.

IMHO that is a workaround for the tp linking bug
[IOW, there is no need to check for tp->root == NULL (in the fast path)
if such an illegal tp was never linked to begin with (on the slow
path)].

So those classifiers you point to need to be fixed afterwards (but 
not -stable material).
My thinking of fixing them to do proper init/get as well later.

> Anyway, it's worked for other classifiers like this for some time...

Would you agree that it is/was a bandaid?
Or maybe you have some other fear that this may break something else and
prefer the workaround instead?

cheers,
jamal
