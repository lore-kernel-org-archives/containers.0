From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 0/5][lxc]: Link with USERCR
Date: Wed, 24 Mar 2010 12:22:56 -0700
Message-ID: <20100324192256.GA20031@us.ibm.com>
References: <20100319063912.GA25732@us.ibm.com>
	<1268995457.2575.9.camel@pagloppaglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1268995457.2575.9.camel@pagloppaglop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michel Normand <normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dlezcano-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Michel Normand [normand-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org] wrote:
| Le jeudi 18 mars 2010 =E0 23:39 -0700, Sukadev Bhattiprolu a =E9crit :
| > 2. Build/install lxc_checkpoint and lxc_restart
| > =

| > 	# Do normal LXC build/install of 0.6.5.
| > =

| > 	# Then replace 'lxc-execute', 'lxc-checkpoint', 'lxc-restart' with
| > 	# new version. i.e Apply attached patches and:
| > =

| > 	$ cd src/lxc
| =

| Your patch set is not usable as is, with requirement to apply the patch
| between two sequences of build, and lxc unable to be built with it.
| =

| Please do a patch of automake files and related configure.ac
| rather than to create a Makefile2 file.

Sure, I am working on it and will resend in a couple of days after
addressing Daniel's comments also. If you have other comments on the
code, please let me know.

Sukadev.
