From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 0/7][v8] Container-init signal semantics
Date: Sat, 07 Mar 2009 20:59:56 +0100
Message-ID: <49B2D23C.8000004@free.fr>
References: <20090219030207.GA18783@us.ibm.com> <499D73C8.3090209@free.fr>	 <20090307190428.GA30594@us.ibm.com>  <49B2CE6E.3090501@free.fr> <1236455509.9151.4.camel@bahia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756436AbZCGUAT@vger.kernel.org>
In-Reply-To: <1236455509.9151.4.camel@bahia>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>, Containers <containers@lists.osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com
List-Id: containers.vger.kernel.org

Greg Kurz wrote:
> On Sat, 2009-03-07 at 20:43 +0100, Daniel Lezcano wrote:
>   
>>         case LINUX_REBOOT_CMD_HALT:
>> -               kernel_halt();
>> -               unlock_kernel();
>> -               do_exit(0);
>> +               if (power_off_pid_ns(current->nsproxy->pid_ns)) {
>> +                       kernel_halt();
>> +                       unlock_kernel();
>> +                       do_exit(0);
>> +               }
>>     
>
> Even if current will get SIGKILLed when zap_pid_ns_processes() is
> called, I see no reason it doesn't call do_exit(0).
Right and unlock_kernel too :)
>   
>>                 break;
>>
>>         case LINUX_REBOOT_CMD_POWER_OFF:
>> -               kernel_power_off();
>> -               unlock_kernel();
>> -               do_exit(0);
>> +               if (power_off_pid_ns(current->nsproxy->pid_ns)) {
>> +                       kernel_power_off();
>> +                       unlock_kernel();
>> +                       do_exit(0);
>> +               }
>>     
>
> Same.
>
>   
>>                 break;
>>
>>     
