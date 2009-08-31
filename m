From: Dietmar Maurer <dietmar-YTcQvvOqK21BDgjK7y7TUQ@public.gmane.org>
Subject: RE: [lxc-devel] Memory Resources
Date: Mon, 31 Aug 2009 12:02:53 +0200
Message-ID: <90D306BE6EBC8D428A824FBBA7A3113DE076E24A@ronja.maurer-it.com>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>
	<ac1c4bf20908240245ydbc1b9bxacfcf2398049505c@mail.gmail.com>
	<4A92676A.1080609@free.fr>
	<ac1c4bf20908240327u424bd021t8848cf1cafb24ada@mail.gmail.com>
	<4A9275CB.7030108@free.fr>
	<ac1c4bf20908240431p1fda5a15qd26629618397696@mail.gmail.com>
	<4A929F83.80207@free.fr>
	<20090826104312.97ff028f.kamezawa.hiroyu@jp.fujitsu.com>
	<4A952689.9020704@free.fr>
	<ac1c4bf20908260650x3311d5d3q44631a30205089b7@mail.gmail.com>
	<ac1c4bf20908261625g71dff96cu77190056540cbb7@mail.gmail.com>
	<4A97A448.5050506@free.fr>
	<20090831085606.b7207a76.kamezawa.hiroyu@jp.fujitsu.com>
	<4A9B96B7.9060009@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A9B96B7.9060009-GANU6spQydw@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org" <kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>, "lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

> Yep, interesting and maybe a solution for the application containers.
> In the case of the system container, that will be the distro scripts
> which will mount the /proc directory with the usual mount options. The
> objective is to avoid to modify the distro scripts and let them do the
> work, like mounting /proc. If we use a fuse procfs, we will need to
> change these scripts to do the correct mount, no ? (note we have the
> same problem with /cgroup/meminfo solution).

Don't know, but maybe it is possible to 'map' the 'proc' filesystem type to an existing directory (bind mount)?

- Dietmar
