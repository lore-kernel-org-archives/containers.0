From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 3 Nov 2011 19:03:30 +0000
Message-ID: <20111103190330.02590426@lxorguk.ukuu.org.uk>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
	<4EB2C4A5.6000406@parallels.com>
	<20111103165903.GA4755@Debian-60-squeeze-64-minimal>
	<20111103182101.5037c1e5@lxorguk.ukuu.org.uk>
	<20111103185108.GA5153@Debian-60-squeeze-64-minimal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111103185108.GA5153@Debian-60-squeeze-64-minimal>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Max Kellermann <max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> Putting a reasonable limit on jobs that are expected to run only for a
> limited amount of time, with a limited amount of total resources.  For

fork is an almost irrelevant resource. Address space (ie memory), file
handles and the like are actual constrained resources.

I can't help thinking this is focussing on a completely irrelevant
cornercase issue. It belongs as part of a general resource limiting
cgroup that also deals with memory, I/O and the like. In fact most of
these resources are a balancing act.

Who cares if you have 10,000 threads. We can handle that without trying.
10,000 different mappings is a whole different ball game, and 100,000 file
handles in some configurations might also matter.

In short in your specific environment a fork runaway is a symptom you can
use to detect and sometimes halt the failure case. It's not the actual
resource problem and it doesn't solve the general case.

> Similar existing feature: RLIMIT_CPU.  Millions of users have it in
> their kernels, but nobody uses it nowadays.  And it's not even
> optional.

It's required by the standards, and basically unmeasurable overhead.

> Btw. I have no problem with maintaining this patch (and a whole bunch
> of others) in my proprietary git repository at work forever.  They're
> very useful for my employer.  I'm just trying to be a good citizen by
> sharing them.

Sure - I'm just not seeing that a whole separate cgroup for it is
appropriate or a good plan. Anyone doing real resource management needs
the rest of the stuff anyway.
