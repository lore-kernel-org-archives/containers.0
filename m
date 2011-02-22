From: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Subject: Re: [PATCH 3/5] page_cgroup: make page tracking available for blkio
Date: Tue, 22 Feb 2011 16:27:29 -0700
Message-ID: <20110222162729.054fe596__7858.04397096417$1298418597$gmane$org@bike.lwn.net>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-4-git-send-email-arighi@develer.com>
	<20110222130145.37cb151e@bike.lwn.net>
	<20110222230146.GB23723@linux.develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110222230146.GB23723-fxUVXftIFDlZdMzt4l2sLQC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Wu Fengguang <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 23 Feb 2011 00:01:47 +0100
Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:

> > My immediate observation is that you're not really tracking the "owner"
> > here - you're tracking an opaque 16-bit token known only to the block
> > controller in a field which - if changed by anybody other than the block
> > controller - will lead to mayhem in the block controller.  I think it
> > might be clearer - and safer - to say "blkcg" or some such instead of
> > "owner" here.
> 
> Basically the idea here was to be as generic as possible and make this
> feature potentially available also to other subsystems, so that cgroup
> subsystems may represent whatever they want with the 16-bit token.
> However, no more than a single subsystem may be able to use this feature
> at the same time.

That makes me nervous; it can't really be used that way unless we want to
say that certain controllers are fundamentally incompatible and can't be
allowed to play together.  For whatever my $0.02 are worth (given the
state of the US dollar, that's not a whole lot), I'd suggest keeping the
current mechanism, but make it clear that it belongs to your controller.
If and when another controller comes along with a need for similar
functionality, somebody can worry about making it more general.

jon
