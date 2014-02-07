From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/9] mm: Mark functions as static in page_cgroup.c
Date: Fri, 7 Feb 2014 12:56:11 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1402071255590.4212__31911.7742045366$1391806589$gmane$org@chino.kir.corp.google.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
	<6054d570fc83c3d4f3de240d6da488f876e21450.1391167128.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-2145918811-1391806572=:4212"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6054d570fc83c3d4f3de240d6da488f876e21450.1391167128.git.rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Rashika Kheria <rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-2145918811-1391806572=:4212
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, 7 Feb 2014, Rashika Kheria wrote:

> Mark functions as static in page_cgroup.c because they are not used
> outside this file.
>=20
> This eliminates the following warning in mm/page_cgroup.c:
> mm/page_cgroup.c:177:6: warning: no previous prototype for =E2=80=98__f=
ree_page_cgroup=E2=80=99 [-Wmissing-prototypes]
> mm/page_cgroup.c:190:15: warning: no previous prototype for =E2=80=98on=
line_page_cgroup=E2=80=99 [-Wmissing-prototypes]
> mm/page_cgroup.c:225:15: warning: no previous prototype for =E2=80=98of=
fline_page_cgroup=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reviewed-by: Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>

Acked-by: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
--531381512-2145918811-1391806572=:4212
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--531381512-2145918811-1391806572=:4212--
