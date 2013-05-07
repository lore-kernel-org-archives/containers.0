From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 33/33] blk-throttle: implement proper hierarchy support
Date: Tue, 7 May 2013 09:14:12 -0700
Message-ID: <20130507161412.GA4948__36528.0250357047$1367943270$gmane$org@mtj.dyndns.org>
References: <1367880372-28312-1-git-send-email-tj@kernel.org>
	<1367880372-28312-34-git-send-email-tj@kernel.org>
	<20130507135511.GA7082@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130507135511.GA7082-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Vivek.

On Tue, May 07, 2013 at 09:55:11AM -0400, Vivek Goyal wrote:
> So if somebody does not specify __DEVEL_sane_behavior, hierarchy is
> still broken. Should we continue to display the message in that case?

The message is to warn people of possible behavior changes.  For
blk-throttle, the behaviors are settled now.  Whetner sane_behavior or
not, the hierarchy behaviors aren't gonna change anymore.  The
hindsight is 20/20 and it would probably have been better if we had
done the same for cfq but I was thinking that we could probably do
away with interface versioning at the time.  Ah well... it isn't
optimal but that's what we ended up with.

Thanks.

-- 
tejun
