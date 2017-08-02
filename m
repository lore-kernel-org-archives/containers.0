From: Aleksa Sarai <asarai-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH_v4.1_3/3] Make core_pattern support namespace
Date: Wed, 2 Aug 2017 17:07:19 +1000
Message-ID: <8bb63f0a-d0b7-edf7-6dca-4d12641074b4__39190.938222646$1501657652$gmane$org@suse.de>
References: <1501655849-9149-1-git-send-email-caosf.fnst@cn.fujitsu.com>
	<1501655849-9149-4-git-send-email-caosf.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1501655849-9149-4-git-send-email-caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cao Shufeng <caosf.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, mashimiao.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
List-Id: containers.vger.kernel.org

> Currently, each container shared one copy of coredump setting
> with the host system, if host system changed the setting, each
> running containers will be affected.
> Same story happened when container changed core_pattern, both
> host and other container will be affected.
> 
> For container based on namespace design, it is good to allow
> each container keeping their own coredump setting.

 From what I can see, this is basically setting a per-pidns core_pattern 
(which is hierarchically applied). I'm not sure this actually solves the 
more general problem (that usermode helper settings aren't generally 
namespace-aware) -- and what happens if you have processes in the same 
pidns that have different mount namespaces?

If we _had_ to do it like this I would think it makes more sense to pin 
it to mountns, but I was under the impression that someone was working 
on making usermode helpers play nicer with namespaces.

Just my $0.02.

-- 
Aleksa Sarai
Software Engineer (Containers)
SUSE Linux GmbH
https://www.cyphar.com/
