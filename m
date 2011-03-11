From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2] Documentation: cgroups: Add notes on removing PIDs
	from tasks and cgroups requiring setup
Date: Thu, 10 Mar 2011 19:00:09 -0800
Message-ID: <AANLkTimRDfqm4wCRP1rw8FVbY81=by+V8p5jVEhCLL2G__6180.29326801679$1299812600$gmane$org@mail.gmail.com>
References: <1299776862-6931-1-git-send-email-emunson@mgebm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1299776862-6931-1-git-send-email-emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Mar 10, 2011 at 9:07 AM, Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org> wrote:
> The cgroup documentation does not specify how a process can be removed fr=
om a
> particular group. =A0This patch adds a note at the end of the simple exam=
ple
> about how this is done. =A0Also, some cgroups (like cpusets) require user=
 input
> before a new group can be used. =A0This is noted in the patch as well.
>
> Signed-off-by: Eric B Munson <emunson-CVBTeua0HjReoWH0uzbU5w@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

> ---
> Changes from V1:
> =A0Rework the note about removing a process from a cgroup
> =A0Add note about ns cgroup causing failure when moving processes between=
 groups
>
> =A0Documentation/cgroups/cgroups.txt | =A0 12 ++++++++++++
> =A01 files changed, 12 insertions(+), 0 deletions(-)
>
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cg=
roups.txt
> index 44b8b7a..cbdfb7d 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -349,6 +349,10 @@ To mount a cgroup hierarchy with all available subsy=
stems, type:
> =A0The "xxx" is not interpreted by the cgroup code, but will appear in
> =A0/proc/mounts so may be any useful identifying string that you like.
>
> +Note: Some subsystems do not work without some user input first. =A0For =
instance,
> +if cpusets are enabled the user will have to populate the cpus and mems =
files
> +for each new cgroup created before that group can be used.
> +
> =A0To mount a cgroup hierarchy with just the cpuset and memory
> =A0subsystems, type:
> =A0# mount -t cgroup -o cpuset,memory hier1 /dev/cgroup
> @@ -426,6 +430,14 @@ You can attach the current shell task by echoing 0:
>
> =A0# echo 0 > tasks
>
> +Note: Since every task is always a member of exactly one cgroup in each
> +mounted hierarchy, to remove a task from its current cgroup you must
> +move it into a new cgroup (possibly the root cgroup) by writing to the
> +new cgroup's tasks file.
> +
> +Note: If the ns cgroup is active, moving a process to another cgroup can
> +fail.
> +
> =A02.3 Mounting hierarchies by name
> =A0--------------------------------
>
> --
> 1.7.1
>
>
