From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [lxc-devel] segfault on shutdown if containers running
Date: Mon, 29 Jun 2009 10:44:49 +0200
Message-ID: <4A487F01.6040603@free.fr>
References: <4A42D033.5060202@zombino.com> <4A432714.4040606@free.fr>
	<4A480F08.3040102@zombino.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A480F08.3040102-+878OnfSgr5BDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Adam Majer <adamm-+878OnfSgr5BDgjK7y7TUQ@public.gmane.org>, Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Adam Majer wrote:
> Daniel Lezcano wrote:
>>> Is this a known problem? If not, I'll provide the backtrace.
>> Yes, please, maybe I am missing something but I was not able to
>> reproduce it.
> 
> I see to be failing at being able to safe this segfault. The computer
> has no serial port so I've been trying to get netconsole to work, and it
> does, but the entire OOPS is only visible on local console, not
> transmitted. Only part of the oops is transmitted :(
> 
> 
> [  635.526580] BUG: unable to handle kernel NULL pointer dereference at
> 000000000000009c
> [  635.526692] IP: [<ffffffff803b26f1>] tty_open+0x1e6/0x411
> [  635.526775] PGD 13dd44067 PUD 1379d5067 PMD 0
> [  635.526905] Oops: 0000 [#1] SMP
> [  635.526999] last sysfs file: /sys/devices/virtual/net/lo/operstate
> [  635.527045] CPU 1
> [  635.527110] Modules linked in: netconsole configfs veth nvidia(P)
> binfmt_misc powernow_k8 cpufreq_powersave cpufreq_conservative
> cpufreq_stats cpufreq_userspace tun bridge stp ext2 mbcache it87
> hwmon_vid loop firewire_sbp2 snd_hda_codec_analog snd_hda_intel
> snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_midi
> snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device usblp
> k8temp i2c_nforce2 pcspkr snd evdev asus_atk0110 i2c_core soundcore
> snd_page_alloc button processor xfs exportfs raid1 md_mod
> 
> 
> 
> So, I've copied the stacktrace on paper and typing it back,

Thanks for taking the time to do that !

> Process getty (pid:3940) <<<-- looks like a process in the container?
> 
> chrdev_open + 0x148/0x167
> chrdev_open + 0x0/0x167
> __dentry_open + 0x148/0x260
> do_flip_open + 0x468/0x85a
> alloc_fd + ....
> do_sys_gen + ...
> system_call_fastpath + ....
> 
> RIP tty_open

This stack trace reminds me something :)
Let me check if I can reproduce it with a small program.

Suka ? Are you aware of this bug ?

Thanks
   -- Daniel
