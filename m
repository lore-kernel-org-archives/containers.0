From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] writeback and cgroup
Date: Wed, 18 Apr 2012 14:18:36 -0400
Message-ID: <20120418181836.GD2224__37573.1335174807$1334773169$gmane$org@redhat.com>
References: <20120404145134.GC12676@redhat.com>
	<20120407080027.GA2584@quack.suse.cz>
	<20120410180653.GJ21801@redhat.com>
	<20120410210505.GE4936@quack.suse.cz>
	<20120410212041.GP21801@redhat.com>
	<20120410222425.GF4936@quack.suse.cz>
	<20120411154005.GD16692@redhat.com>
	<20120411154531.GE16692@redhat.com>
	<20120411170542.GB16008@quack.suse.cz>
	<20120417214831.GE19975@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120417214831.GE19975-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sjayaraman-IBi9RG/b67k@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 17, 2012 at 02:48:31PM -0700, Tejun Heo wrote:
[..]

> As for priority inversion through shared request pool, it is a problem
> which needs to be solved regardless of how async IOs are throttled.
> I'm not determined to which extent yet tho.  Different cgroups
> definitely need to be on separate pools but do we also want
> distinguish sync and async and what about ioprio?  Maybe we need a
> bybrid approach with larger common pool and reserved ones for each
> class?

currently we have global pool with separate limits for sync and async
and there is no consideration of ioprio. I think to keep it simple we
can just extend the same notion to keep per cgroup pool with internal
limits on sync/async requests to make sure sync IO does not get
serialized behind async IO. Personally I am not too worried about
async IO prio. It has never worked.

Thanks
Vivek
