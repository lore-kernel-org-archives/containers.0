From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: question about default values for per-namespace settings
Date: Thu, 15 May 2014 13:48:50 -0400
Message-ID: <20140515174850.GB20738__24853.1820172959$1400176145$gmane$org@mtj.dyndns.org>
References: <20140512140706.GA22082@macbook.localnet>
	<cover.1399909529.git.vvs@openvz.org>
	<5370F781.7010909@parallels.com> <53711B21.1060309@pandora.be>
	<53712B0A.7060007@parallels.com> <53727246.4050306@pandora.be>
	<53748280.60906@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <53748280.60906-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vasily Averin <vvs-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Thu, May 15, 2014 at 01:01:52PM +0400, Vasily Averin wrote:
> how do you think, which defaults should be used for per-namespace settings in general case
> and for per-netns sysctls especially? Do we have some common position about this or
> perhaps we already have some setting that allows to select desired behavior?

Unfortunately, I don't have much idea on the subject.  Serge and
others on the containers list should know a lot better than me.

Thanks.

-- 
tejun
