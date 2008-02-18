From: Andreas Schwab <schwab-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7] CGroup API: Update cpusets to use cgroup
	structured file API
Date: Mon, 18 Feb 2008 12:52:12 +0100
Message-ID: <jewsp24h3n.fsf__42714.2325127081$1203335736$gmane$org@sykes.suse.de>
References: <20080215204418.535025000@menage.corp.google.com>
	<20080215204821.778088000@menage.corp.google.com>
	<20080216212901.70fe35ce.pj@sgi.com> <47B9560F.3030402@cn.fujitsu.com>
	<47B96805.7070002@linux.vnet.ibm.com>
	<20080218111333.GA6333@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080218111333.GA6333-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org> (Balbir Singh's message
	of "Mon\, 18 Feb 2008 16\:43\:33 +0530")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> @@ -238,7 +238,7 @@ rmdir() if there are no tasks.
>  The type of memory accounted by the cgroup can be limited to just
>  mapped pages by writing "1" to memory.control_type field
>  =

> -echo -n 1 > memory.control_type
> +echo > memory.control_type

Looks like you stripped too much here.

Andreas.

-- =

Andreas Schwab, SuSE Labs, schwab-l3A5Bk7waGM@public.gmane.org
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
