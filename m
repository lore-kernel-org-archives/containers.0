From: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: introduce cgroup_taskset and consolidate
	subsys methods, take#2
Date: Fri, 26 Aug 2011 07:56:09 -0700
Message-ID: <CALdu-PBthm1AcRX1UOAQEpXVWMU60UEPjMEcLDig3vZOawT9-A__28034.7867789262$1314370717$gmane$org@mail.gmail.com>
References: <1314312192-26885-1-git-send-email-tj@kernel.org>
	<4E5753D3.9080500@cn.fujitsu.com>
	<20110826140900.GF2632@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110826140900.GF2632-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Aug 26, 2011 at 7:09 AM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Hello,
>
> On Fri, Aug 26, 2011 at 04:05:39PM +0800, Li Zefan wrote:
>> It's fine for me to route those patches through pm-freezer, since this
>> work is initiated and needed for the work on freezer.
>
> Awesome. =A0Paul, what do you think? =A0Rafael, if Paul agrees, can you
> please take in this series?
>

Sure - but can you make sure that there's nothing in -mm that
conflicts with this patchset? If there is, then maybe cherry-pick
those into pm-freezer too, and fix them up?

Paul
