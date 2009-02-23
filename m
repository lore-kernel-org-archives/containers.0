From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: debugging threaded apps running under a clone(CLONE_NEWPID)
Date: Mon, 23 Feb 2009 12:21:53 -0600
Message-ID: <20090223182153.GD13151@us.ibm.com>
References: <499EE0D1.1010001@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756368AbZBWSWV@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <499EE0D1.1010001@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Cedric Le Goater <clg@fr.ibm.com>
Cc: Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

Quoting Cedric Le Goater (clg@fr.ibm.com):
> Hello !
> 
> to debug threaded apps, gdb uses a special libthread_db which seeks in the
> symbols of the exec the list of running threads. This list contains the glibc 
> 'struct pthread' descriptor with pids and tids which values are relative 
> to the namespace in which the threads were created.  
> 
> unless you run gdb in the same pid namespace, gdb will not see any thread
> in the debugged app. this is frustrating for some scenarios and some 
> support from the kernel would be needed to address this issue. Here
> are some ideas :
> 
>    . enter a pid namespace. hard.  
> 
>    . expose the pid numbers of a task in its pid namespaces, through some 
>      ways like /proc/self/stat or /proc/self/pids and modify gdb to make 
>      the conversion.
> 
> How would you do it ? 

perhaps a /proc/$$/vpid which prints out
	task_pid_nr_ns(tsk, current->nsproxy->pidns)
then each thread opens an fd for /proc/self/vpid and passes it
over an af_unix socket to the parent gdb, which then reads it
to get the pid in its own ns?

-serge
