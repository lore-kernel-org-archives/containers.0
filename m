From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [RFC] bpf: tracing: new helper bpf_get_current_cgroup_ino
Date: Tue, 22 May 2018 20:35:51 -0700
Message-ID: <20180523033550.z3tqo4lhd3zrmtdu__24920.464869547$1527046456$gmane$org@ast-mbp>
References: <20180513173318.21680-1-alban@kinvolk.io>
	<20180521162609.lpdrnozowmzdn57m@ast-mbp.dhcp.thefacebook.com>
	<CAH3MdRWgruVq+3r+2pHTah-c2zTO03vPkepjWDZ0_KrYcroy9A@mail.gmail.com>
	<CAH3MdRVdfw52atavT3KL8MpPw7zDM_hR6aUcqDP1PogLn_sH+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAH3MdRVdfw52atavT3KL8MpPw7zDM_hR6aUcqDP1PogLn_sH+w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Y Song <ys114321-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alban Crequy <alban.crequy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 22, 2018 at 08:33:24PM -0700, Y Song wrote:
> +       struct cgroup *cgrp = task_dfl_cgroup(current);
> +       if (!cgrp)
> +               return -EINVAL;

why this check is needed?
