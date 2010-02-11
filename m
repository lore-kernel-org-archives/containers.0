From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [lxc-devel] [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column
Date: Thu, 11 Feb 2010 10:19:02 -0800
Message-ID: <20100211181902.GA3742@us.ibm.com>
References: <20100211042531.GA8835@us.ibm.com>
	<1265882900.2591.65.camel@pagloppaglop>
	<1265883662.2591.68.camel@pagloppaglop>
	<20100211155446.GC6884@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100211155446.GC6884-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, dlezcano-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| Quoting Michel Normand (normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
| > Le jeudi 11 f=E9vrier 2010 =E0 11:08 +0100, Michel Normand a =E9crit :
| > > Le mercredi 10 f=E9vrier 2010 =E0 20:25 -0800, Sukadev Bhattiprolu a =
=E9crit :
| > > > From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
| > > > Date: Wed, 10 Feb 2010 20:09:17 -0800
| > > > Subject: [PATCH 1/1] lxc-ps: Nit - Avoid blank CONTAINER column
| > > > =

| > > > The contianer name is not printed in the lxc-ps output unless the -=
-lxc
| > > > option is specified.  But the CONTAINER column is printed (and left
| > > > blank) even if the --lxc option is not specified.
| > > > =

| > > > 	$ /usr/local/bin/lxc-ps -n foo
| > > > 	CONTAINER    PID TTY          TIME CMD
| > > > 		   19525 pts/2    00:00:01 bash
| > > > 		   20311 pts/2    00:00:00 lxc-ps
| > > > 		   20312 pts/2    00:00:00 ps
| > > =

| > > For me the error in the script is =

| > > to report default pid of ps command,
| > > rather than to report the pids of specified 'foo' =

| > > container in this case.
| > > =

| > > So a patch should address this point,
| > > rather to remove the container column.
| > =

| > In fact there is no error in the script :)
| > The -n option for lxc-ps is a ps option ! =


Ah, good point. Like Serge pointed, I got the -n mixed up with other
lxc- commands.

Even so, I still think the blank CONTAINER column is misleading.
Does it mean that the listed processes are not part of any container ?
Like /bin/ps which prints, say the PGID column, only when selected,
wouldn't it make sense to print the CONTAINER column only when necessary ?

Thanks,

Sukadev
